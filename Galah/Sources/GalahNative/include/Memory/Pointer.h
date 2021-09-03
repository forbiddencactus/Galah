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

#ifndef Pointer_h
#define Pointer_h

#include "GalahNative.h"

// This is to avoid all the weird casting Swift does, probably expensive?
typedef struct
{
    void* ptr;
}   GPtr;

// Returns a pointer added by amount*typesize. 
GPtr ptr_add(GPtr ptr, MemSize typesize, GUInt amount);

// Returns a pointer subtracted by amount*typesize.
GPtr ptr_sub(GPtr ptr, MemSize typesize, GUInt amount);

// Used to (try to?) avoid pointless type casting, sets a GPtr from a void*.
void ptr_set(GPtr* outptr, void* inptr);

// Assigns the value of inassignptr into the location pointed to by ptr. 
void ptr_assign(GPtr* ptr, void* inassignptr, MemSize size);

// Sets the value of inptr to NULL.
void ptr_setnull(GPtr* inptr);

#endif
