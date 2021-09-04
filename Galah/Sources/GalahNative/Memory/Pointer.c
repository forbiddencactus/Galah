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
// A wrapper for simple pointer operations.

#include "Memory/Pointer.h"
#include "Memory/Alloc.h"

GPtr ptr_add(GPtr ptr, MemSize typesize, GUInt amount)
{
    GPtr ret;
    ret.ptr = ptr.ptr + (amount * typesize);
    return ret;
}

GPtr ptr_sub(GPtr ptr, MemSize typesize, GUInt amount)
{
    GPtr ret;
    ret.ptr = ptr.ptr - (amount * typesize);
    return ret;
}

// Returns a pointer pointing to sourcePtr.
GPtr ptr_get_ptr_to_ptr(GPtr sourcePtr)
{
    GPtr ret;
    ret.ptr = &sourcePtr.ptr;
    return ret;
}

void ptr_set(GPtr* outptr, void* inptr)
{
    outptr->ptr = inptr;
}

// Assigns the value of inassignptr into the location pointed to by ptr.
void ptr_assign(GPtr* ptr, void* inassignptr, MemSize size)
{
    glh_memcpy(ptr->ptr, inassignptr, size);
}

void ptr_setnull(GPtr* inptr)
{
    inptr->ptr = NULL;
}
