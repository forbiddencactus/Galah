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
#include "Thread/Thread.h"


typedef struct
{
    volatile GJob* jobBuffer;
    GVolatileUInt16 capacity;
    GVolatileUInt16 count;
}GJobManagerJobList;

// Inits and allocs the buffer for the job list. Returns true if successful.
bool glh_threadmanager_initjoblist(GJobManagerJobList* jobList);

// Copies the specified job into the job list and returns its job id.
GJobID glh_threadmanager_initjob(GJobManagerJobList* jobList, const GJobData* jobData);

#endif
