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
// Functions to simplify job stuff. 

#ifndef Job_h
#define Job_h

#include "Thread/Thread.h"

typedef GUInt16 GJobID;
typedef void (*glh_job_callback)(GJobID,void*);

typedef struct
{
    glh_thread_function task;
    
    // The 5 word buffer can hold an existential container for a type conforming to one protocol, or whatever you want.
    void* taskDataExistentialContainer[5]; // See https://github.com/apple/swift/blob/main/docs/ABI/TypeLayout.rst
} GTask;

typedef struct
{
    GTask job;
    GTask jobFinished;
    void* threadData;
    GJobID jobID;
    GVolatileBool isComplete;
} GJob;

typedef struct
{
    volatile GJob* job[GALAH_JOB_JOBBUFFER_SIZE]; // Shared by both.
    GVolatileUInt16 writeIndex; // Shared
    GVolatileUInt16 readIndex; // Shared
}GJobBuffer;

typedef struct
{
    GThread gThread;
    GJobBuffer* jobBuffer; // Shared.
    GVolatileBool shouldExit; // Shared.
    GVolatileBool shouldRun; // Shared. Set to false to pause the job thread.
} GJobThread;

// Initialises the GJobThread pointed to by *thread. 
int glh_job_createjobthread(GJobThread* thread, glh_thread_function func, GJobBuffer* jobBuffer);

// Clears the specified job struct.
void glh_job_clear(GJob* job);

// Clears the supplied job buffer.
void glh_job_clearjobbuffer(GJobBuffer* jobBuffer);

// Returns true if the job buffer has space for a job.
bool glh_job_canaddjob(GJobBuffer* jobBuffer);

// Adds the job to the specified job buffer. Returns true if success.
bool glh_job_pushjob(GJobBuffer* jobBuffer, GJob* job);

// Replaces the job in the jobBuffer position with NULL and returns the previous value.
GJob* glh_job_jobbuffer_popjob(GJobBuffer* jobBuffer, GUInt16 readIndex);

// Returns the read index for this job buffer.
GUInt16 glh_job_jobbuffer_getreadindex(GJobBuffer* jobBuffer);

// Returns the write index for this job buffer.
GUInt16 glh_job_jobbuffer_getwriteindex(GJobBuffer* jobBuffer);

// Increase the read index for this job buffer. Returns the increased read index.
GUInt16 glh_job_jobbuffer_increasereadindex(GJobBuffer* jobBuffer);

// Increase the write index for this job buffer. Returns the increased write index.
GUInt16 glh_job_jobbuffer_increasewriteindex(GJobBuffer* jobBuffer);

// Kills the thread. If clearThread is true, it also wipes the thread struct clean.
void glh_job_killjobthread(GJobThread* thread, bool clearThread);

#endif /* Job_h */
