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
// A circular buffer for our thread manager.

#include "Thread/ThreadManager.h"
#include "Memory/Alloc.h"
#include "Thread/Atomic.h"
#include "Debug/Debug.h"

void glh_jobmanager_clearjobbuffer(GJobManager* jobManager)
{
    jobManager->capacity = 0;
    jobManager->count = 0;
    jobManager->jobBuffer = NULL;
}

void glh_jobmanager_emptyjobbuffer(GJobManager* jobManager)
{
    jobManager->count = 0;
    glh_memset((void*)jobManager->jobBuffer, 0, sizeof(GJob) * jobManager->capacity);
}

bool glh_jobmanager_initjobmanager(GJobManager* jobManager)
{
    glh_jobmanager_clearjobbuffer(jobManager);
    jobManager->capacity = GALAH_JOB_JOBBUFFER_SIZE;
    
    jobManager->jobBuffer = glh_malloc(sizeof(GJob) * jobManager->capacity);
    jobManager->jobDependencies = glh_malloc(sizeof(GJobDependencies) * jobManager->capacity);

    
    if(jobManager->jobBuffer != NULL)
    {
        return true;
    }
    
    glh_jobmanager_clearjobbuffer(jobManager);
    return false;
}

GJobID glh_jobmanager_initjob(GJobManager* jobManager, GTask job, GTask jobComplete, void* threadData)
{
    GUInt16 listCount = glh_atomic_add_uint16(jobManager->count, 1, GAtomicSeqCst);
    GUInt16 listCapacity = glh_atomic_fetch_uint16(jobManager->capacity, GAtomicSeqCst);
    
    // We need to block here if the existing job buffer has run out. 
    while(listCount >= listCapacity)
    {
        listCapacity = glh_atomic_fetch_uint16(jobManager->capacity, GAtomicSeqCst);
        
        // It is this thread's job to grow the buffer. All other jobs stall.
        if(listCount == listCapacity)
        {
            GUInt16 newCapacity = listCapacity * 2;
            volatile GJob* oldBuffer = jobManager->jobBuffer;
            volatile GJobDependencies* oldJobDependencies = jobManager->jobDependencies;
            
            volatile GJob* newBuffer = glh_malloc(sizeof(GJob) * newCapacity);
            GJobDependencies* newJobDependencies = glh_malloc(sizeof(GJobDependencies) * newCapacity);

            glh_debug_assert(newBuffer != NULL);
            glh_memcpy((void*)newBuffer, (void*)oldBuffer, sizeof(GJob) * listCapacity);
            glh_memcpy((void*)newJobDependencies, (void*)oldJobDependencies, sizeof(GJobDependencies) * listCapacity);

            glh_free((void*)oldBuffer);
            glh_atomic_set_ptr((GVolatileVoidPtr**)&jobManager->jobBuffer, (GVolatileVoidPtr*)newBuffer, GAtomicSeqCst);
            glh_atomic_set_uint16(&jobManager->capacity, newCapacity, GAtomicSeqCst);
        }
    }
    
    GJob newJob;
    glh_job_clear(&newJob);
    newJob.jobID = listCount;
    newJob.job = job;
    newJob.jobFinished = jobComplete;
    newJob.threadData = threadData;
    
    glh_memcpy((void*)jobManager->jobBuffer + newJob.jobID, &newJob, sizeof(GJob));
    
    return newJob.jobID;
}

// Returns a pointer to the specified job from its job ID.
GJob* glh_jobmanager_getjob(GJobManager* jobManager, GJobID jobID)
{
    return (GJob*)(jobManager->jobBuffer + jobID);
}

// Returns true if the specified job's job dependencies have finished running.
bool glh_jobmanager_jobdependenciescomplete(GJobManager* jobManager, GJobID jobID)
{
    if(jobManager->count >= jobID) { return false; }
    
    if(jobID == 0) { return true; } // Job 0 can never have any dependencies.
    
    for(int i = 0; i < GALAH_JOB_DEPENDENCY_CAPACITY; i++)
    {
        GJobID idToCheck = (jobManager->jobDependencies + jobID)->jobDependencies[i];
        
        if( !(jobManager->jobBuffer + jobID)->isComplete) 
        {
            return false;
        }
        
        if(idToCheck == 0)
        {
            // Assume this means we can early out from this loop. Make sure if there's a job zero, that it's always the last.
            return true;
        }
    }
}
