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
// Wrapper around C standard lib alloc stuff, for potential platform abstraction.

#ifndef Alloc_h
#define Alloc_h

#include "GalahNative.h"

void* glh_malloc(MemSize size);

__attribute__((__forceinline)) // Force inline or else alloca will cause severe havok.
void* glh_alloca(MemSize size);

void glh_free(void* ptr);

void* glh_memcpy(void* dest, const void* src, MemSize size);

void* glh_memmove(void* dest, const void* src, MemSize size);

void* glh_memset(void* dest, int value, MemSize size);

#endif
