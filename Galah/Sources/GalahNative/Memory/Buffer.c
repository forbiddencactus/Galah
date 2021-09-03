//---- Galah Engine---------------------------------------------------------//
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

// Allocs a NativeBuffer that will hold capacity amount of elements of elementSize.
NativeBuffer buffer_create(MemSize elementSize, GUInt capacity, bool isAutoResize)
{
    NativeBuffer buf;
    buf.bufferSize = elementSize * capacity;
    buf.buffer = glh_malloc(buf.bufferSize);
    buf.elementSize = elementSize;
    buf.capacity = capacity;
    buf.isAutoResize = isAutoResize;
    
    buf.count = 0;
    
    return buf;
}

// Adds an element to the end of the buffer, and returns the index. -1 if add failed.
int buffer_add(NativeBuffer* buf, const void* element)
{
    if(buffer_makespace(buf, buf->count) == NULL)
    {
        return -1;
    }
    
    glh_memcpy(buf->buffer + (buf->elementSize * buf->count - 1), element, buf->elementSize);
    
    return buf->count - 1;
}

// Inserts an element to index position in the buffer, and returns the index. -1 if insert failed.
int buffer_insert(NativeBuffer* buf, const void* element, GUInt index)
{
    if(buffer_makespace(buf, index) == NULL)
    {
        return -1;
    }
    
    //Copy the new element...
    glh_memcpy(buf->buffer + (buf->elementSize * index), element, buf->elementSize);
    
    return index;
}

// Removes an element at the index position in the buffer, and returns the new count. -1 if remove failed.
int buffer_remove(NativeBuffer* buf, GUInt index)
{
    if(index < buf->count)
    {
        if(index != (buf->count -1))
        {
            MemSize size = buf->count - index;
            glh_memmove(buf->buffer + (buf->elementSize * index), buf->buffer + (buf->elementSize * (index + 1)), size);
        }
        return --buf->count;
    }
    
    return -1;
}

// Removes elements from startIndex to endIndex, including endIndex.
int buffer_remove_range(NativeBuffer* buf, GUInt startIndex, GUInt endIndex)
{
    if(endIndex > startIndex && endIndex < buf->count)
    {
        GUInt amount = (endIndex - startIndex) + 1;
        MemSize moveSize = amount * buf->elementSize;
        
        if(endIndex != (buf->count -1))
        {
            glh_memmove(buf->buffer + (buf->elementSize * startIndex),buf->buffer + buf->elementSize * (endIndex + 1), moveSize);
        }
        return buf->count - amount;
    }
    
    return -1;
}

// Gets the element at position index. Returns null if failed.
void* buffer_get(NativeBuffer* buf, GUInt index)
{
    if(index < buf->count)
    {
        return buf->buffer + (buf->elementSize * index);
    }
    
    return NULL;
}

// Attempts to grow the buffer to newCapacity. Returns true if successful.
bool buffer_grow(NativeBuffer* buf, GUInt newCapacity)
{
    if(buf->capacity >= newCapacity)
    {
        return false;
    }
    
    Buff* oldBuffer = buf->buffer;
    buf->buffer = glh_malloc(buf->elementSize * newCapacity);
    
    if(buf->buffer != NULL)
    {
        glh_memcpy(buf->buffer, oldBuffer, buf->bufferSize);
        buf->capacity = newCapacity;
        buf->bufferSize = buf->elementSize * buf->capacity;
        glh_free(oldBuffer);
        return true;
    }
    else
    {
        buf->buffer = oldBuffer;
    }
    
    return false;
}

// Makes space for an element and returns the pointer for that element's place in the buffer.
void* buffer_makespace(NativeBuffer* buf, GUInt atIndex)
{
    if(buf->count >= buf->capacity)
    {
        if(buf->isAutoResize)
        {
            if(!buffer_grow(buf, buf->capacity * 2))
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
        MemSize movesize = buf->count - atIndex;
        glh_memmove(buf->buffer + (buf->elementSize * (atIndex + 1)), buf->buffer + (buf->elementSize * atIndex),movesize * buf->elementSize);
    }
    
    buf->count++;
    
    return buf->buffer + (buf->elementSize * atIndex);
}

bool buffer_free(NativeBuffer* buf)
{
    glh_free(buf->buffer);
    buf->buffer = NULL;
}
