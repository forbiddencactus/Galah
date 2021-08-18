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

#ifndef Buffer_h
#define Buffer_h

#include "GalahNative.h"
typedef struct
{
    size_t elementSize;
    size_t bufferSize;
    uint count;
    uint capacity;
    Buff* buffer;
    bool isAutoResize;
}   NativeBuffer;

//Note: all of these will memcpy elements into buffer!
//Autoresize will always resize capacity * 2.

// Allocs a NativeBuffer that will hold capacity amount of elements of elementSize.
NativeBuffer buffer_create(size_t elementSize, uint capacity, bool isAutoResize);

// Adds an element to the end of the buffer, and returns the index. -1 if add failed.
int buffer_add(NativeBuffer* buf, void* element);

// Inserts an element to index position in the buffer, and returns the index. -1 if insert failed.
int buffer_insert(NativeBuffer* buf, void* element, uint index);

// Removes an element at the index position in the buffer, and returns the new count. -1 if remove failed.
int buffer_remove(NativeBuffer* buf, uint index);

// Gets the element at position index. Returns null if failed. 
void* buffer_get(NativeBuffer* buf, uint index);

// Attempts to grow the buffer to newCapacity. Returns true if successful.
bool buffer_grow(NativeBuffer* buf, uint newCapacity);

// Attempts to free the buffer. Returns true if success.
bool buffer_free(NativeBuffer* buf);

#endif
