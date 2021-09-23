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
// Wrapper around low level pointer libraries, for use in our higher level threads/jobs.

#ifndef Thread_h
#define Thread_h
#include "GalahNative.h"

typedef void (*glh_thread_function)(void*);

typedef struct
{
    void* nativethreadptr;
    bool hasJob;
    glh_thread_function job;
    void* jobArg;
    bool shouldExit;
} GThread;

/*
 * NOTE: This stuff is fairly minimalistic and relies on ownership to maintain thread safety.
 * As a guide, nativethreadptr, and shouldExit are 'owned' by the main/owner thread, and can only
 * be read by the child thread. hasJob, job, and jobArg can only be set by the owner thread, and
 * cleared by the child thread. hasJob relies on the CPU's atomic set instruction to remain thread safe,
 * and should be checked for false by the owner thread before "setting".
 */
 
// Initialises the GThread pointed to by *thread. Thread will autosleep when it has no work. 
int glh_thread_create(GThread* thread);

// Sets the job to the specified thread and wakes the thread.
bool glh_thread_setjob(GThread* thread, glh_thread_function job, void* jobArg);

// Kills the thread.
void glh_thread_killthread(GThread* thread);

#endif
