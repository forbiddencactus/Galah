/*
MIT License

Copyright © 2020, 2021 Alexis Griffin.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "Memory/Buffer.h"

// Allocs a NativeBuffer that will hold capacity amount of elements of elementSize.
NativeBuffer buffer_create(size_t elementSize, uint capacity, bool isAutoResize)
{
    NativeBuffer buf;
    buf.buffer = malloc(elementSize * capacity);
    buf.elementSize = elementSize;
    buf.capacity = capacity;
    buf.isAutoResize = isAutoResize;
    buf.count = 0;
    
    return buf;
}

// Adds an element to the end of the buffer, and returns the index. -1 if add failed.
int buffer_add(NativeBuffer* buf, void* element)
{
    if(buf->count >= buf->capacity)
    {
        if(buf->isAutoResize)
        {
            if(!buffer_grow(buf, buf->capacity * 2))
            {
                return -1;
            }
        }
        else
        {
            return -1;
        }
    }
    memcpy(buf->buffer + (buf->elementSize * buf->count), element, buf->elementSize);
    buf->count += 1;
    
    return buf->count - 1;
}

// Inserts an element to index position in the buffer, and returns the index. -1 if insert failed.
int buffer_insert(NativeBuffer* buf, void* element, uint index)
{
    if(index >= buf->count)
    {
        return -1;
    }
        
    if(buf->count >= buf->capacity)
    {
        if(buf->isAutoResize)
        {
            if(!buffer_grow(buf, buf->capacity * 2))
            {
                return -1;
            }
        }
        else
        {
            return -1;
        }
    }
    //Make space for the element...
    size_t movesize = buf->count - index;
    memmove(buf->buffer + (buf->elementSize * (index + 1)), buf->buffer + (buf->elementSize * index),movesize * buf->elementSize);
    //Copy the new element...
    memcpy(buf->buffer + (buf->elementSize * index), element, buf->elementSize);
    
    return index;
}

// Removes an element at the index position in the buffer, and returns the new count. -1 if remove failed.
int buffer_remove(NativeBuffer* buf, uint index)
{
    if(index < buf->count)
    {
        size_t size = buf->count - index;
        memmove(buf->buffer + (buf->elementSize * index), buf->buffer + (buf->elementSize * (index + 1)), size);
        return --buf->count;
    }
    
    return -1;
}

// Gets the element at position index. Returns null if failed.
void* buffer_get(NativeBuffer* buf, uint index)
{
    if(index < buf->count)
    {
        return buf->buffer + (buf->elementSize * index);
    }
    
    return NULL;
}

// Attempts to grow the buffer to newCapacity. Returns true if successful.
bool buffer_grow(NativeBuffer* buf, uint newCapacity)
{
    if(buf->capacity >= newCapacity)
    {
        return false;
    }
    
    Buff* oldBuffer = buf->buffer;
    buf->buffer = malloc(buf->elementSize * newCapacity);
    
    if(buf->buffer != NULL)
    {
        memcpy(buf->buffer, oldBuffer, buf->capacity);
        buf->capacity = newCapacity;
        free(oldBuffer);
        return true;
    }
    else
    {
        buf->buffer = oldBuffer;
    }
    
    return false;
}

bool buffer_free(NativeBuffer* buf)
{
    free(buf->buffer);
    buf->buffer = NULL;
}
