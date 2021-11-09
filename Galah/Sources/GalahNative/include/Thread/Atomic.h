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
// Fences for lockless threads. 

#ifndef Barrier_h
#define Barrier_h

#include "GalahNative.h"

// Compare and swap.
bool glh_compare_and_swap_uint(GVolatileUInt* ptr, GUInt old, GVolatileUInt new);

// Compare and swap.
bool glh_compare_and_swap_uint64(GVolatileUInt64* ptr, GUInt64 old, GVolatileUInt64 new);

// Compare and swap.
bool glh_compare_and_swap_bool(GVolatileBool* ptr, bool old, bool new);

// Adds the add amount to the specified object. Returns the result.
GUInt64 glh_atomic_add_uint64(GVolatileUInt64* obj, GUInt64 add);

// Sets the value of the boolean obj to the value of set.
void glh_atomic_set_bool(GVolatileBool* obj, bool set);

// Atomically returns the value of obj.
bool glh_atomic_fetch_bool(GVolatileBool* obj);
                            
// Sets the value of the int obj to the value of set.
void glh_atomic_set_uint64(GVolatileUInt64* obj, GVolatileUInt64 set);

// Atomically returns the value of obj.
GVolatileUInt64 glh_atomic_fetch_uint64(GVolatileUInt64* obj);

#endif
