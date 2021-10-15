//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020, 2021, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// A simple buffer, to do buffer things with.

#include "Memory/Buffer.h"
#include "Memory/Alloc.h"

void buffer_runElementsMovedCallback(GBuffer* buf)
{
    if( buf->bufferElementsMovedCallback != NULL)
    {
        buf->bufferElementsMovedCallback(buf->bufferElementsMovedCallbackTarget);
    }
}

// Allocs a GBuffer that will hold capacity amount of elements of elementSize.
GBuffer buffer_create(GMemSize elementSize, GUInt capacity, bool isAutoResize)
{
    GBuffer buf;
    buf.bufferSize = elementSize * capacity;
    buf.buffer = glh_malloc(buf.bufferSize);
    buf.elementSize = elementSize;
    buf.capacity = capacity;
    buf.isAutoResize = isAutoResize;
    buf.bufferResizeCallbackTarget = NULL;
    buf.bufferResizeCallback = NULL;
    buf.bufferElementsMovedCallbackTarget = NULL;
    buf.bufferElementsMovedCallback = NULL;
    buf.autoGrowAmount = 0;
    
    buf.count = 0;
    
    // Memset this friend.
    glh_memset(buf.buffer, 0, buf.bufferSize);
    
    return buf;
}

// Adds an element to the end of the buffer, and returns the index. -1 if add failed.
int buffer_add(GBuffer* buf, const void* element)
{
    if(buffer_makespace(buf, buf->count) == NULL)
    {
        return -1;
    }
    
    glh_memcpy(buf->buffer + (buf->elementSize * buf->count - 1), element, buf->elementSize);
    
    return buf->count - 1;
}

// Inserts an element to index position in the buffer, and returns the index. -1 if insert failed.
int buffer_insert(GBuffer* buf, const void* element, GUInt index)
{
    if(buffer_makespace(buf, index) == NULL)
    {
        return -1;
    }
    
    //Copy the new element...
    return buffer_replace(buf, element, index);
}

// Replaces the element at index with the specified element.
int buffer_replace(GBuffer* buf, const void* element, GUInt index)
{
    glh_memcpy(buf->buffer + (buf->elementSize * index), element, buf->elementSize);
    
    return index;
}

// Removes an element at the index position in the buffer, and returns the new count. -1 if remove failed.
int buffer_remove(GBuffer* buf, GUInt index)
{
    if(index < buf->count)
    {
        if(index != (buf->count -1))
        {
            GMemSize size = buf->count - index;
            glh_memmove(buf->buffer + (buf->elementSize * index), buf->buffer + (buf->elementSize * (index + 1)), size);
            buffer_runElementsMovedCallback(buf);
        }
        return --buf->count;
    }
    
    return -1;
}

// Removes elements from startIndex to endIndex, including endIndex.
int buffer_remove_range(GBuffer* buf, GUInt startIndex, GUInt endIndex)
{
    if(endIndex > startIndex && endIndex < buf->count)
    {
        GUInt amount = (endIndex - startIndex) + 1;
        GMemSize moveSize = amount * buf->elementSize;
        
        if(endIndex != (buf->count -1))
        {
            glh_memmove(buf->buffer + (buf->elementSize * startIndex),buf->buffer + buf->elementSize * (endIndex + 1), moveSize);
            buffer_runElementsMovedCallback(buf);
        }
        buf->count-= amount;
        return buf->count;
    }
    
    return -1;
}

// Gets the element at position index. Returns null if failed.
void* buffer_get(GBuffer* buf, GUInt index)
{
    if(index < buf->count)
    {
        return buf->buffer + (buf->elementSize * index);
    }
    
    return NULL;
}

// Attempts to grow the buffer to newCapacity. Returns true if successful.
bool buffer_grow(GBuffer* buf, GUInt newCapacity)
{
    if(buf->capacity >= newCapacity)
    {
        return false;
    }
    
    Buff* oldBuffer = buf->buffer;
    GMemSize newSize = buf->elementSize * newCapacity;
    buf->buffer = glh_malloc(newSize);
    
    if(buf->buffer != NULL)
    {
        glh_memcpy(buf->buffer, oldBuffer, buf->bufferSize);
        buf->capacity = newCapacity;
        buf->bufferSize = newSize;
        glh_free(oldBuffer);
        
        if( buf->bufferResizeCallback != NULL)
        {
            buf->bufferResizeCallback(buf->bufferResizeCallbackTarget);
        }
        
        return true;
    }
    else
    {
        buf->buffer = oldBuffer;
    }
    
    return false;
}

// Sets whether the buffer should auto resize.
void buffer_set_shouldautoresize(GBuffer* buf, bool shouldAutoResize)
{
    buf->isAutoResize = shouldAutoResize;
}

// Sets the buffer autogrow amount (0 means the buffer will duplicate in size)
void buffer_set_autogrow_amount(GBuffer* buf, GUInt newAutoGrowAmount)
{
    buf->autoGrowAmount = newAutoGrowAmount;
}

// Returns the new size for the buffer should it autogrow.
GUInt buffer_get_autogrow_amount(GBuffer* buf)
{
    if(buf->autoGrowAmount == 0)
    {
        return buf->capacity * 2;
    }
    
    return buf->autoGrowAmount;
}

// Makes space for an element and returns the pointer for that element's place in the buffer.
void* buffer_makespace(GBuffer* buf, GUInt atIndex)
{
    if(buf->count >= buf->capacity)
    {
        if(buf->isAutoResize)
        {
            if(!buffer_grow(buf, buffer_get_autogrow_amount(buf)))
            {
                return NULL;
            }
        }
        else
        {
            return NULL;
        }
    }
    
    if(atIndex > buf->count)
    {
        return NULL;
    }
    
    if(atIndex < (buf->count) )
    {
        //Make space for the element...
        GMemSize movesize = buf->count - atIndex;
        glh_memmove(buf->buffer + (buf->elementSize * (atIndex + 1)), buf->buffer + (buf->elementSize * atIndex),movesize * buf->elementSize);
        glh_memset(buf->buffer + (buf->elementSize * atIndex), 0, atIndex);
        buffer_runElementsMovedCallback(buf);
    }
    
    buf->count++;
    
    return buf->buffer + (buf->elementSize * atIndex);
}

// Sets a callback for the buffer to call whenever it resizes.
bool buffer_addresizecallback(GBuffer* buf, GBufferCallback callback, void* target)
{
    if( buf->bufferResizeCallback == NULL && buf->bufferResizeCallbackTarget == NULL)
    {
        buf->bufferResizeCallback = callback;
        buf->bufferResizeCallbackTarget = target;
        return true;
    }
    
    return false;
}

// Sets a callback for the buffer to call whenever the elements inside it are moved around.
bool buffer_addelementsmovedcallback(GBuffer* buf, GBufferCallback callback, void* target)
{
    if( buf->bufferElementsMovedCallback == NULL && buf->bufferElementsMovedCallbackTarget == NULL)
    {
        buf->bufferElementsMovedCallback = callback;
        buf->bufferElementsMovedCallbackTarget = target;
        return true;
    }
    
    return false;
}

bool buffer_free(GBuffer* buf)
{
    glh_free(buf->buffer);
    buf->buffer = NULL;
}
