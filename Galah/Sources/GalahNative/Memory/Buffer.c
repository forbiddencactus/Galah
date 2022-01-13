//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020 - 2022, the Galah contributors.
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

#define data(_buf_) buffer_get_data(_buf_)

// Allocs a GBuffer that will hold capacity amount of elements of elementSize.
GBuffer buffer_create(GMemSize elementSize, GUInt capacity, bool isAutoResize)
{
    GBuffer buffer;
    GBufferPtr* bufPtr = NULL;
    GMemSize dataSize = sizeof(GBufferBody);
    
    GBufferData bufData;
    bufData.bufferSize = dataSize + bufData.bufferBodySize;
    bufData.bufferBodySize = elementSize * capacity;
    bufData.elementSize = elementSize;
    bufData.capacity = capacity;
    bufData.isAutoResize = isAutoResize;
    bufData.bufferResizeCallbackTarget = NULL;
    bufData.bufferResizeCallback = NULL;
    bufData.bufferElementsMovedCallbackTarget = NULL;
    bufData.bufferElementsMovedCallback = NULL;
    bufData.autoGrowAmount = 0;
    bufData.count = 0;
    
    bufPtr = glh_malloc(bufData.bufferSize);
    
    if(bufPtr != NULL)
    {
        bufData.bufferBody = bufPtr + dataSize;
    
        // Memset this friend.
        glh_memset(bufData.bufferBody, 0, dataSize + bufData.bufferBodySize);
    
        // Memcpy the data to the beginning of the buffer
        glh_memcpy(bufPtr, &bufData, dataSize);
    }
    
    buffer.bufferPtr = bufPtr;
    
    return buffer;
}

// Allocs a GBuffer using an existing GBuffer.
GBuffer buffer_create_with_copy(GBuffer* buf)
{
    GBuffer returnBuf;
    GBufferData* bufData = data(buf);
    returnBuf.bufferPtr = NULL;
    
    returnBuf.bufferPtr = glh_malloc(bufData->bufferSize);
    
    if( returnBuf.bufferPtr != NULL )
    {
        glh_memcpy(returnBuf.bufferPtr, buf->bufferPtr, bufData->bufferSize);
    }

    return returnBuf;
}

// Returns a pointer to the buffer data struct in the buffer.
GBufferData* buffer_get_data(GBuffer* buffer)
{
    return (GBufferData*)buffer->bufferPtr;
}

// Adds an element to the end of the buffer, and returns the index. -1 if add failed.
int buffer_add(GBuffer* buf, const void* element)
{
    GBufferData* bufData = data(buf);
    if(buffer_makespace(buf, bufData->count) == NULL)
    {
        return -1;
    }
    else
    {
        bufData = data(buf);
    }
    
    glh_memcpy(bufData->bufferBody + (bufData->elementSize * bufData->count - 1), element, bufData->elementSize);
    
    return bufData->count - 1;
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
    GBufferData* bufData = data(buf);
    glh_memcpy(bufData->bufferBody + (bufData->elementSize * index), element, bufData->elementSize);
    
    return index;
}

// Removes an element at the index position in the buffer, and returns the new count. -1 if remove failed.
int buffer_remove(GBuffer* buf, GUInt index)
{
    GBufferData* bufData = data(buf);
    if(index < bufData->count)
    {
        if(index != (bufData->count -1))
        {
            GMemSize size = bufData->count - index;
            glh_memmove(bufData->bufferBody + (bufData->elementSize * index), bufData->bufferBody + (bufData->elementSize * (index + 1)), size);
            if( bufData->bufferElementsMovedCallback != NULL)
            {
                bufData->bufferElementsMovedCallback(bufData->bufferElementsMovedCallbackTarget);
            }
        }
        return --bufData->count;
    }
    
    return -1;
}

// Removes elements from startIndex to endIndex, including endIndex.
int buffer_remove_range(GBuffer* buf, GUInt startIndex, GUInt endIndex)
{
    GBufferData* bufData = data(buf);
    if(endIndex > startIndex && endIndex < bufData->count)
    {
        GUInt amount = (endIndex - startIndex) + 1;
        GMemSize moveSize = amount * bufData->elementSize;
        
        if(endIndex != (bufData->count -1))
        {
            glh_memmove(bufData->bufferBody + (bufData->elementSize * startIndex),bufData->bufferBody + bufData->elementSize * (endIndex + 1), moveSize);
            if( bufData->bufferElementsMovedCallback != NULL)
            {
                bufData->bufferElementsMovedCallback(bufData->bufferElementsMovedCallbackTarget);
            }
        }
        bufData->count-= amount;
        return bufData->count;
    }
    
    return -1;
}

// Gets the element at position index. Returns null if failed.
void* buffer_get(GBuffer* buf, GUInt index)
{
    GBufferData* bufData = data(buf);
    if(index < bufData->count)
    {
        return bufData->bufferBody + (bufData->elementSize * index);
    }
    
    return NULL;
}

// Attempts to grow the buffer to newCapacity. Returns true to new buffer if successful.
GBuffer* buffer_grow(GBuffer* buf, GUInt newCapacity)
{
    GBufferData* oldBufData = data(buf);

    if(oldBufData->capacity >= newCapacity)
    {
        return false;
    }
    
    GMemSize dataSize = sizeof(GBufferData);
    GBufferPtr* oldBuffer = buf->bufferPtr;
    GBufferPtr* newBuffer = NULL;
    GMemSize newBufferBodySize = oldBufData->elementSize * newCapacity;
    GMemSize newSize = dataSize + newBufferBodySize;
    newBuffer = glh_malloc(newSize);
    
    if(newBuffer != NULL)
    {
        // Memcpy the new data...
        glh_memcpy(newBuffer, oldBufData, dataSize);
        
        GBufferData* newBufData = data(newBuffer);
        newBufData->capacity = newCapacity;
        newBufData->bufferBodySize = newBufferBodySize;
        newBufData->bufferBody = newBuffer + dataSize;
        newBufData->bufferSize = newSize;
        
        // Memset this friend.
        glh_memset(newBufData->bufferBody, 0, newBufData->bufferBodySize);
    
        // Memcpy the old buffer body to the new buffer body.
        glh_memcpy(newBufData->bufferBody, oldBufData->bufferBody, oldBufData->bufferBodySize);

        glh_free(oldBuffer);
        
        buf->bufferPtr = newBuffer;
        
        if( newBufData->bufferResizeCallback != NULL)
        {
            newBufData->bufferResizeCallback(newBufData->bufferResizeCallbackTarget);
        }
        
        return true;
    }
    
    return false;
}

// Sets whether the buffer should auto resize.
void buffer_set_shouldautoresize(GBuffer* buf, bool shouldAutoResize)
{
    GBufferData* bufData = data(buf);
    bufData->isAutoResize = shouldAutoResize;
}

// Sets the buffer autogrow amount (0 means the buffer will duplicate in size)
void buffer_set_autogrow_amount(GBuffer* buf, GUInt newAutoGrowAmount)
{
    GBufferData* bufData = data(buf);
    bufData->autoGrowAmount = newAutoGrowAmount;
}

// Returns the new size for the buffer should it autogrow.
GUInt buffer_get_autogrow_amount(GBuffer* buf)
{
    GBufferData* bufData = data(buf);
    if(bufData->autoGrowAmount == 0)
    {
        return bufData->capacity * 2;
    }
    
    return bufData->autoGrowAmount;
}

// Makes space for an element and returns the pointer for that element's place in the buffer.
void* buffer_makespace(GBuffer* buf, GUInt atIndex)
{
    GBufferData* bufData = data(buf);
    if(bufData->count >= bufData->capacity)
    {
        if(bufData->isAutoResize)
        {
            if(!buffer_grow(buf, buffer_get_autogrow_amount(buf)))
            {
                return NULL;
            }
            else
            {
                bufData = data(buf); // Ptr to the data changed!
            }
        }
        else
        {
            return NULL;
        }
    }
    
    if(atIndex > bufData->count)
    {
        return NULL;
    }
    
    if(atIndex < (bufData->count) )
    {
        //Make space for the element...
        GMemSize movesize = bufData->count - atIndex;
        glh_memmove(bufData->bufferBody + (bufData->elementSize * (atIndex + 1)), bufData->bufferBody + (bufData->elementSize * atIndex),movesize * bufData->elementSize);
        glh_memset(bufData->bufferBody + (bufData->elementSize * atIndex), 0, atIndex);
        
        if( bufData->bufferElementsMovedCallback != NULL)
        {
            bufData->bufferElementsMovedCallback(bufData->bufferElementsMovedCallbackTarget);
        }
    }
    
    bufData->count++;
    
    return bufData->bufferBody + (bufData->elementSize * atIndex);
}

// Sets a callback for the buffer to call whenever it resizes.
bool buffer_addresizecallback(GBuffer* buf, GBufferCallback callback, void* target)
{
    GBufferData* bufData = data(buf);
    if( bufData->bufferResizeCallback == NULL && bufData->bufferResizeCallbackTarget == NULL)
    {
        bufData->bufferResizeCallback = callback;
        bufData->bufferResizeCallbackTarget = target;
        return true;
    }
    
    return false;
}

// Sets a callback for the buffer to call whenever the elements inside it are moved around.
bool buffer_addelementsmovedcallback(GBuffer* buf, GBufferCallback callback, void* target)
{
    GBufferData* bufData = data(buf);
    if( bufData->bufferElementsMovedCallback == NULL && bufData->bufferElementsMovedCallbackTarget == NULL)
    {
        bufData->bufferElementsMovedCallback = callback;
        bufData->bufferElementsMovedCallbackTarget = target;
        return true;
    }
    
    return false;
}

bool buffer_free(GBuffer* buf)
{
    GBufferData* bufData = data(buf);
    
    // Memset so it's obvious when stuff is dealloc.
#if GALAH_DEBUG
    glh_memset(buf->bufferPtr, 0, bufData->bufferSize);
#endif
    glh_free(buf->bufferPtr);
    buf->bufferPtr = NULL;
}
