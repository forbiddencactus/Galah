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

typedef GUInt GThreadID;
typedef GUInt16 GJobID;
typedef void (*glh_thread_function)(void*);
typedef void (*glh_job_callback)(GJobID,void*);

typedef struct
{
    glh_thread_function job;
    glh_job_callback jobFinishedCallback;
    void* jobArg;
    void* jobCallbackArg;
    void* threadData;
} GJobData;

typedef struct
{
    GJobData jobData;
    GJobID jobID;
    GVolatileBool isComplete;
} GJob;

typedef struct
{
    volatile GJob* job[GALAH_THREAD_JOBBUFFER_SIZE]; // Shared by both.
    GVolatileUInt32 writeIndex; // Shared
    GVolatileUInt32 readIndex; // Shared
}GJobBuffer;

typedef struct
{
    void* nativethreadptr; // Owned by thread.
    GJobBuffer* jobBuffer; // Shared.
    GVolatileBool isRunning; // Owned by thread.
    GVolatileBool shouldExit; // Shared.
    GVolatileUInt threadIndex; // Owned by thread. Set once during creation. 
} GThread;

/*
 * NOTE: This stuff is fairly minimalistic and relies on ownership to maintain thread safety.
 * Threads should only be owned by their spawning thread.
 */
 
// Initialises the GThread pointed to by *thread. Thread will autosleep when it has no work. 
int glh_thread_create(GThread* thread, GJobBuffer* jobBuffer);

// Returns an empty jobdata struct. 
GJobData glh_thread_getemptydata();

// Clears the specified job data struct.
void glh_thread_job_cleardata(GJobData* jobData);

// Clears the supplied job buffer.
void glh_thread_clearjobbuffer(GJobBuffer* jobBuffer);

// Clears the specified job struct.
void glh_thread_job_clear(GJob* job);

// Sets the job to the specified thread and wakes the thread.
bool glh_thread_addjob(GThread* thread, GJob* job);

// Returns true if the thread has space in its job buffer for a job.
bool glh_thread_canaddjob(GThread* thread);

// Gets the thread id of the thread this function is called from. 
GThreadID glh_thread_getid();

// Returns the pointer at _Thread_local void* threadData, which gets initialised from the Job data. 
void* glh_thread_getthreaddata();

// Kills the thread. If clearThread is true, it also wipes the thread struct clean.
void glh_thread_killthread(GThread* thread, bool clearThread);

#endif
