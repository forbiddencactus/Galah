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
// Wrapper around C standard lib alloc stuff, for potential platform abstraction.

#include "Memory/Alloc.h"

void* glh_malloc(MemSize size)
{
    return malloc(size);
}

void* glh_alloca(MemSize size)
{
    return alloca(size);
}

void glh_free(void* ptr)
{
    free(ptr);
}

void* glh_memcpy(void* dest, const void* src, MemSize size)
{
    return memcpy(dest, src, size);
}

void* glh_memmove(void* dest, const void* src, MemSize size)
{
    return memmove(dest, src, size);
}

void* glh_memset(void* dest, int value, MemSize size)
{
    return memset(dest, value, size);
}
