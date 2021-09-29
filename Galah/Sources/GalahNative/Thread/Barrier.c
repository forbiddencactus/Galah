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

/*
 https://preshing.com/20130922/acquire-and-release-fences/
 https://www.cl.cam.ac.uk/~pes20/cpp/cpp0xmappings.html
 https://preshing.com/20120710/memory-barriers-are-like-source-control-operations/
 https://preshing.com/20120913/acquire-and-release-semantics/
 https://preshing.com/20120930/weak-vs-strong-memory-models/
 https://randomascii.wordpress.com/2020/11/29/arm-and-lock-free-programming/
*/


#include "Thread/Barrier.h"
#include <stdatomic.h>

inline void glh_fence_acquire()
{
    atomic_thread_fence(memory_order_acquire);
}

inline void glh_fence_release()
{
    atomic_thread_fence(memory_order_release);
}
