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
// C side of our thread manager.

#ifndef ThreadManager_h
#define ThreadManager_h
#include "Thread/Job.h"

typedef struct
{
    GJobID jobDependencies[20];
} GJobDependencies;

typedef struct
{
    volatile GJob* jobBuffer;
    volatile GJobDependencies* jobDependencies;
    GVolatileUInt16 capacity;
    GVolatileUInt16 count;
}GJobManager;

// Inits and allocs the buffer for the job list. Returns true if successful.
bool glh_threadmanager_initjobmanager(GJobManager* jobManager);

// Empties the job list of jobs at the end of the frame.
void glh_threadmanager_emptyjobbuffer(GJobManager* jobManager);

// Copies the specified job into the job list and returns its job id.
GJobID glh_threadmanager_initjob(GJobManager* jobManager, GTask job, GTask jobComplete, void* threadData);

// Returns a pointer to the specified job from its job ID.
GJob* glh_threadmanager_getjob(GJobManager* jobManager, GJobID jobID);

#endif
