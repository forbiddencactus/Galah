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
// Fences for lockless threads, atomics, and such things.

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
void glh_atomic_exchange_ptr(GVolatileVoidPtr** ptr, GVolatileVoidPtr** val, GVolatileVoidPtr** ret)
{
    __atomic_exchange(ptr,val,ret,__ATOMIC_SEQ_CST);
}

// Compare and swap.
bool glh_atomic_compare_and_swap_uint(GVolatileUInt* ptr, GUInt old, GVolatileUInt new)
{
    return __atomic_compare_exchange(ptr, &old, &new, false, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
}

bool glh_atomic_compare_and_swap_uint64(GVolatileUInt64* ptr, GUInt64 old, GVolatileUInt64 new)
{
    return __atomic_compare_exchange(ptr, &old, &new, false, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
}

bool glh_atomic_compare_and_swap_bool(GVolatileBool* ptr, bool old, bool new)
{
    return __atomic_compare_exchange(ptr, &old, &new, false, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
}

// Adds the add amount to the specified object. Returns the result.
GUInt glh_atomic_add_uint(GVolatileUInt* obj, GUInt add)
{
    return __atomic_add_fetch(obj, add, __ATOMIC_SEQ_CST);
}

// Adds the add amount to the specified object. Returns the result.
GUInt16 glh_atomic_add_uint16(GVolatileUInt16* obj, GUInt16 add)
{
    return __atomic_add_fetch(obj, add, __ATOMIC_SEQ_CST);
}

// Adds the add amount to the specified object. Returns the result.
GUInt32 glh_atomic_add_uint32(GVolatileUInt32* obj, GUInt32 add)
{
    return __atomic_add_fetch(obj, add, __ATOMIC_SEQ_CST);
}

// Adds the add amount to the specified object. Returns the result.
GUInt64 glh_atomic_add_uint64(GVolatileUInt64* obj, GUInt64 add)
{
    return __atomic_add_fetch(obj, add, __ATOMIC_SEQ_CST);
}

// Sets the value of the boolean obj to the value of set.
void glh_atomic_set_bool(GVolatileBool* obj, bool set)
{
    __atomic_store(obj, &set, __ATOMIC_SEQ_CST);
}

// Atomically returns the value of obj.
bool glh_atomic_fetch_bool(GVolatileBool* obj)
{
    bool retVal;
    __atomic_load(obj, &retVal, __ATOMIC_SEQ_CST);
    return retVal;
}

// Sets the value of the int obj to the value of set.
void glh_atomic_set_uint16(GVolatileUInt16* obj, GUInt16 set)
{
    __atomic_store(obj, &set, __ATOMIC_SEQ_CST);
}

// Sets the value of the int obj to the value of set.
void glh_atomic_set_uint32(GVolatileUInt32* obj, GUInt32 set)
{
    __atomic_store(obj, &set, __ATOMIC_SEQ_CST);
}
                            
// Sets the value of the int obj to the value of set.
void glh_atomic_set_uint64(GVolatileUInt64* obj, GUInt64 set)
{
    __atomic_store(obj, &set, __ATOMIC_SEQ_CST);
}

// Atomically sets the value of the ptr to the value of set.
void glh_atomic_set_ptr(GVolatileVoidPtr** obj, GVolatileVoidPtr* set)
{
    __atomic_store(obj, &set, __ATOMIC_SEQ_CST);

}

// Atomically returns the value of obj.
GVolatileUInt16 glh_atomic_fetch_uint16(GVolatileUInt16* obj)
{
    GUInt16 retVal;
    __atomic_load(obj, &retVal, __ATOMIC_SEQ_CST);
    return retVal;
}

// Atomically returns the value of obj.
GVolatileUInt32 glh_atomic_fetch_uint32(GVolatileUInt32* obj)
{
    GUInt32 retVal;
    __atomic_load(obj, &retVal, __ATOMIC_SEQ_CST);
    return retVal;
}


// Atomically returns the value of obj.
GVolatileUInt64 glh_atomic_fetch_uint64(GVolatileUInt64* obj)
{
    GUInt64 retVal;
    __atomic_load(obj, &retVal, __ATOMIC_SEQ_CST);
    return retVal;
}

// Sets the value of the int obj to the value of set.
void glh_atomic_set_uint(GVolatileUInt* obj, GVolatileUInt set)
{
    __atomic_store(obj, &set, __ATOMIC_SEQ_CST);
}

// Atomically returns the value of obj.
GVolatileUInt glh_atomic_fetch_uint(GVolatileUInt* obj)
{
    GUInt retVal;
    __atomic_load(obj, &retVal, __ATOMIC_SEQ_CST);
    return retVal;
}

// Atomically returns the value of obj.
GVolatileVoidPtr* glh_atomic_fetch_ptr(GVolatileVoidPtr** obj)
{
    GVolatileVoidPtr* retVal;
    __atomic_load(obj, &retVal, __ATOMIC_SEQ_CST);
    return retVal;
}
