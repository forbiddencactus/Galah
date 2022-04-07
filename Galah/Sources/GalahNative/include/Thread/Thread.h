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
// Wrapper around low level pointer libraries, for use in our higher level threads/jobs.

#ifndef Thread_h
#define Thread_h
#include "GalahNative.h"

typedef void (*glh_thread_function)(void*);

typedef struct
{
    glh_thread_function job[GALAH_THREAD_JOBBUFFER_SIZE]; // Shared by both.
    void* jobArg[GALAH_THREAD_JOBBUFFER_SIZE]; // Shared by both.
    GVolatileUInt writeIndex; // Owned by main thread.
    GVolatileUInt readIndex; // Owned by thread.

}GJobBuffer;

typedef struct
{
    void* nativethreadptr; // Owned by main. 
    GJobBuffer jobBuffer; // Shared.
    GVolatileBool isRunning; // Owned by thread.
    GVolatileBool shouldExit; // Owned by main thread.
    GVolatileUInt threadIndex; // Owned by thread. Set once during creation. 
} GThread;

/*
 * NOTE: This stuff is fairly minimalistic and relies on ownership to maintain thread safety.
 * Threads should only be owned by their spawning thread.
 */
 
// Initialises the GThread pointed to by *thread. Thread will autosleep when it has no work. 
int glh_thread_create(GThread* thread);

// Sets the job to the specified thread and wakes the thread.
bool glh_thread_addjob(GThread* thread, glh_thread_function job, void* jobArg);

// Gets the thread id of the thread this function is called from. 
GUInt glh_thread_getid();

// Kills the thread.
void glh_thread_killthread(GThread* thread);

#endif
