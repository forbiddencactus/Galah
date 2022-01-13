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

#ifndef Buffer_h
#define Buffer_h

#include "GalahNative.h"

typedef void (*GBufferCallback)(void*);
typedef void GBufferBody;
typedef void GBufferPtr;

// We are wrapping the pointer to the actual buffer data in a struct (which should also be pointed to in any function that takes the buffer as an input). The idea is that if the bufferPtr needs to change, things won't get too hairy in the owner data in Swift. The struct syntax just makes the Swift syntax less hairy.
typedef struct
{
    GBufferPtr* bufferPtr;
} GBuffer;

typedef struct
{
    GMemSize elementSize;
    GMemSize bufferSize;
    GMemSize bufferBodySize;
    GUInt count;
    GUInt capacity;
    GBufferBody* bufferBody;
    bool isAutoResize;
    void* bufferResizeCallbackTarget;
    GBufferCallback bufferResizeCallback;
    void* bufferElementsMovedCallbackTarget;
    GBufferCallback bufferElementsMovedCallback;
    
    //0 means the buffer will auto grow by just doubling its capacity, any other integer means the buffer will autoGrow by elementSize * the integer.
    GUInt autoGrowAmount;
    
}   GBufferData;

//Note: all of these will memcpy elements into buffer!

// Allocs a GBuffer that will hold capacity amount of elements of elementSize.
GBuffer buffer_create(GMemSize elementSize, GUInt capacity, bool isAutoResize);

// Allocs a GBuffer using an existing GBuffer.
GBuffer buffer_create_with_copy(GBuffer* buf);

// Returns a pointer to the buffer data struct in the buffer. 
GBufferData* buffer_get_data(GBuffer* buffer);

// Adds an element to the end of the buffer, and returns the index. -1 if add failed.
int buffer_add(GBuffer* buf, const void* element);

// Inserts an element to index position in the buffer, and returns the index. -1 if insert failed.
int buffer_insert(GBuffer* buf, const void* element, GUInt index);

// Replaces the element at index with the specified element.
int buffer_replace(GBuffer* buf, const void* element, GUInt index);

// Removes an element at the index position in the buffer, and returns the new count. -1 if remove failed.
int buffer_remove(GBuffer* buf, GUInt index);

// Removes elements from startIndex to endIndex, including endIndex.
int buffer_remove_range(GBuffer* buf, GUInt startIndex, GUInt endIndex);

// Gets the element at position index. Returns null if failed. 
void* buffer_get(GBuffer* buf, GUInt index);

// Attempts to grow the buffer to newCapacity. Returns true if successful.
GBuffer* buffer_grow(GBuffer* buf, GUInt newCapacity);

// Sets whether the buffer should auto resize.
void buffer_set_shouldautoresize(GBuffer* buf, bool shouldAutoResize);

// Sets the buffer autogrow amount (0 means the buffer will duplicate in size)
void buffer_set_autogrow_amount(GBuffer* buf, GUInt newAutoGrowAmount);

// Returns the new size for the buffer should it autogrow.
GUInt buffer_get_autogrow_amount(GBuffer* buf);

// Makes space for an element and returns the pointer for that element's place in the buffer.
void* buffer_makespace(GBuffer* buf, GUInt atIndex);

// Sets a callback for the buffer to call whenever it resizes. 
bool buffer_addresizecallback(GBuffer* buf, GBufferCallback callback, void* target);

// Sets a callback for the buffer to call whenever the elements inside it are moved around. 
bool buffer_addelementsmovedcallback(GBuffer* buf, GBufferCallback callback, void* target);

// Attempts to free the buffer. Returns true if success.
bool buffer_free(GBuffer* buf);

#endif
