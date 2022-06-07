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
// Fences, atomics, and such things.

/*
 https://preshing.com/20130922/acquire-and-release-fences/
 https://www.cl.cam.ac.uk/~pes20/cpp/cpp0xmappings.html
 https://preshing.com/20120710/memory-barriers-are-like-source-control-operations/
 https://preshing.com/20120913/acquire-and-release-semantics/
 https://preshing.com/20120930/weak-vs-strong-memory-models/
 https://randomascii.wordpress.com/2020/11/29/arm-and-lock-free-programming/
*/


#include "Thread/Atomic.h"
#include <stdatomic.h>


// Stores contents of val into ptr, and stores previous contents of ptr into ret.
void glh_atomic_exchange_ptr(GVolatileVoidPtr** ptr, GVolatileVoidPtr** val, GVolatileVoidPtr** ret, GAtomicOrdering ordering)
{
    __atomic_exchange(ptr, val, ret, ordering);
}

// Compare and swap.
bool glh_atomic_compare_and_swap_uint(GVolatileUInt* ptr, GUInt old, GVolatileUInt new, GAtomicOrdering ordering)
{
    return __atomic_compare_exchange(ptr, &old, &new, false, ordering, ordering);
}

bool glh_atomic_compare_and_swap_uint64(GVolatileUInt64* ptr, GUInt64 old, GVolatileUInt64 new, GAtomicOrdering ordering)
{
    return __atomic_compare_exchange(ptr, &old, &new, false, ordering, ordering);
}

bool glh_atomic_compare_and_swap_bool(GVolatileBool* ptr, bool old, bool new, GAtomicOrdering ordering)
{
    return __atomic_compare_exchange(ptr, &old, &new, false, ordering, ordering);
}

// Adds the add amount to the specified object. Returns the result.
GUInt glh_atomic_add_uint(GVolatileUInt* obj, GUInt add, GAtomicOrdering ordering)
{
    return __atomic_add_fetch(obj, add, ordering);
}

// Adds the add amount to the specified object. Returns the result.
GUInt8 glh_atomic_add_uint8(GVolatileUInt8* obj, GUInt8 add, GAtomicOrdering ordering)
{
    return __atomic_add_fetch(obj, add, ordering);
}

// Adds the add amount to the specified object. Returns the result.
GUInt16 glh_atomic_add_uint16(GVolatileUInt16* obj, GUInt16 add, GAtomicOrdering ordering)
{
    return __atomic_add_fetch(obj, add, ordering);
}

// Adds the add amount to the specified object. Returns the result.
GUInt32 glh_atomic_add_uint32(GVolatileUInt32* obj, GUInt32 add, GAtomicOrdering ordering)
{
    return __atomic_add_fetch(obj, add, ordering);
}

// Adds the add amount to the specified object. Returns the result.
GUInt64 glh_atomic_add_uint64(GVolatileUInt64* obj, GUInt64 add, GAtomicOrdering ordering)
{
    return __atomic_add_fetch(obj, add, ordering);
}

// Sets the value of the boolean obj to the value of set.
void glh_atomic_set_bool(GVolatileBool* obj, bool set, GAtomicOrdering ordering)
{
    __atomic_store(obj, &set, ordering);
}

// Atomically returns the value of obj.
bool glh_atomic_fetch_bool(GVolatileBool* obj, GAtomicOrdering ordering)
{
    bool retVal;
    __atomic_load(obj, &retVal, ordering);
    return retVal;
}

// Sets the value of the int obj to the value of set.
void glh_atomic_set_uint16(GVolatileUInt16* obj, GUInt16 set, GAtomicOrdering ordering)
{
    __atomic_store(obj, &set, ordering);
}

// Sets the value of the int obj to the value of set.
void glh_atomic_set_uint32(GVolatileUInt32* obj, GUInt32 set, GAtomicOrdering ordering)
{
    __atomic_store(obj, &set, ordering);
}
                            
// Sets the value of the int obj to the value of set.
void glh_atomic_set_uint64(GVolatileUInt64* obj, GUInt64 set, GAtomicOrdering ordering)
{
    __atomic_store(obj, &set, ordering);
}

// Atomically sets the value of the ptr to the value of set.
void glh_atomic_set_ptr(GVolatileVoidPtr** obj, GVolatileVoidPtr* set, GAtomicOrdering ordering)
{
    __atomic_store(obj, &set, ordering);

}

// Atomically returns the value of obj.
GVolatileUInt8 glh_atomic_fetch_uint8(GVolatileUInt8* obj, GAtomicOrdering ordering)
{
    GUInt8 retVal;
    __atomic_load(obj, &retVal, ordering);
    return retVal;
}

// Atomically returns the value of obj.
GVolatileUInt16 glh_atomic_fetch_uint16(GVolatileUInt16* obj, GAtomicOrdering ordering)
{
    GUInt16 retVal;
    __atomic_load(obj, &retVal, ordering);
    return retVal;
}

// Atomically returns the value of obj.
GVolatileUInt32 glh_atomic_fetch_uint32(GVolatileUInt32* obj, GAtomicOrdering ordering)
{
    GUInt32 retVal;
    __atomic_load(obj, &retVal, ordering);
    return retVal;
}


// Atomically returns the value of obj.
GVolatileUInt64 glh_atomic_fetch_uint64(GVolatileUInt64* obj, GAtomicOrdering ordering)
{
    GUInt64 retVal;
    __atomic_load(obj, &retVal, ordering);
    return retVal;
}

// Sets the value of the int obj to the value of set.
void glh_atomic_set_uint(GVolatileUInt* obj, GVolatileUInt set, GAtomicOrdering ordering)
{
    __atomic_store(obj, &set, ordering);
}

// Atomically returns the value of obj.
GVolatileUInt glh_atomic_fetch_uint(GVolatileUInt* obj, GAtomicOrdering ordering)
{
    GUInt retVal;
    __atomic_load(obj, &retVal, ordering);
    return retVal;
}

// Atomically returns the value of obj.
GVolatileVoidPtr* glh_atomic_fetch_ptr(GVolatileVoidPtr** obj, GAtomicOrdering ordering)
{
    GVolatileVoidPtr* retVal;
    __atomic_load(obj, &retVal, ordering);
    return retVal;
}
