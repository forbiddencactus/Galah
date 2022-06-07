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

#include "Thread/Job.h"
#include "Thread/Atomic.h"
#include <pthread.h>


// Clears a thread struct clean.
void glh_job_clear_jobthread(GJobThread* thread)
{
    glh_thread_clear(&thread->gThread);
    thread->shouldExit = false;
    thread->jobBuffer = NULL;
}

// Initialises the GJobThread pointed to by *thread.
int glh_job_createjobthread(GJobThread* thread, glh_thread_function func, GJobBuffer* jobBuffer)
{
    // Wipe our struct clean...
    glh_job_clear_jobthread(thread);
    
    thread->jobBuffer = jobBuffer;
    
    return glh_thread_createthread(&thread->gThread, func, (void*) thread);
}


// Clears the specified job struct.
void glh_job_clear(GJob* job)
{
    void* emptyarr[5] = {NULL, NULL, NULL, NULL, NULL};
    job->job.task = NULL;
    memset(job->job.taskDataExistentialContainer, NULL, 5);
    job->jobFinished.task = NULL;
    memset(job->jobFinished.taskDataExistentialContainer, NULL, 5);
    job->jobID = 0;
    job->isComplete = false;
}

// Clears the supplied job buffer.
void glh_job_clearjobbuffer(GJobBuffer* jobBuffer)
{
    for(int i = 0; i < GALAH_JOB_JOBBUFFER_SIZE; i++)
    {
        jobBuffer->job[i] = NULL;
    }
    
    jobBuffer->readIndex = 0;
    jobBuffer->writeIndex = 0;
}

// Returns the read index for this job buffer.
GUInt16 glh_job_jobbuffer_getreadindex(GJobBuffer* jobBuffer)
{
    GUInt16 rawReadIndex = glh_atomic_fetch_uint16(&jobBuffer->readIndex, GAtomicSeqCst);
    return rawReadIndex % GALAH_JOB_JOBBUFFER_SIZE;
}

// Returns the write index for this job buffer.
GUInt16 glh_job_jobbuffer_getwriteindex(GJobBuffer* jobBuffer)
{
    GUInt16 rawWriteIndex = glh_atomic_fetch_uint16(&jobBuffer->writeIndex, GAtomicSeqCst);
    return rawWriteIndex % GALAH_JOB_JOBBUFFER_SIZE;
}

// Increase the read index for this job buffer. Returns the increased read index.
GUInt16 glh_job_jobbuffer_increasereadindex(GJobBuffer* jobBuffer)
{
    GUInt16 rawReadIndex = glh_atomic_add_uint16(&jobBuffer->readIndex, 1, GAtomicSeqCst);
    return rawReadIndex % GALAH_JOB_JOBBUFFER_SIZE;
}

// Increase the write index for this job buffer. Returns the increased write index.
GUInt16 glh_job_jobbuffer_increasewriteindex(GJobBuffer* jobBuffer)
{
    GUInt16 rawWriteIndex = glh_atomic_add_uint16(&jobBuffer->writeIndex, 1, GAtomicSeqCst);
    return rawWriteIndex % GALAH_JOB_JOBBUFFER_SIZE;
}

// Adds the job to the specified job buffer. Returns true if successful.
bool glh_job_pushjob(GJobBuffer* jobBuffer, GJob* job)
{
    GUInt writeIndex = glh_job_jobbuffer_increasewriteindex(jobBuffer);
    
    if(glh_atomic_fetch_ptr((GVolatileVoidPtr**)&jobBuffer->job[writeIndex], GAtomicSeqCst) == NULL)
    {
        glh_atomic_set_ptr((GVolatileVoidPtr**)&jobBuffer->job[writeIndex],job, GAtomicSeqCst);
        
        return true;
    }
    return false;
}

// Replaces the job in the jobBuffer position with NULL and returns the previous value.
GJob* glh_job_jobbuffer_popjob(GJobBuffer* jobBuffer, GUInt16 readIndex)
{
    GJob* returnJob;
    glh_atomic_exchange_ptr((GVolatileVoidPtr**)&jobBuffer->job[readIndex], NULL, (GVolatileVoidPtr**)&returnJob, GAtomicSeqCst);
    return returnJob;
}

// Returns true if the job buffer has space for a job.
bool glh_job_canaddjob(GJobBuffer* jobBuffer)
{
    GVolatileUInt rawWriteIndex = glh_atomic_fetch_uint16(&jobBuffer->writeIndex, GAtomicSeqCst);
    GUInt writeIndex = rawWriteIndex % GALAH_JOB_JOBBUFFER_SIZE;

    if(glh_atomic_fetch_ptr((GVolatileVoidPtr**)&jobBuffer->job[writeIndex], GAtomicSeqCst) == NULL)
    {
        return true;
    }
    
    return false;
}

// Kills the thread.
void glh_job_killjobthread(GJobThread* thread, bool clearThread)
{
    if(thread->gThread.nativethreadptr != NULL)
    {
        thread->shouldExit = true;
        pthread_kill(thread->gThread.nativethreadptr, SIGCONT);
        
        // To avoid any drama, we'll wait for the thread to end before continuing...
        pthread_join(thread->gThread.nativethreadptr, NULL);
        
        // Sending signals to dead threads is undefined behaviour. Indicate the thread is gone.
        thread->gThread.nativethreadptr = NULL;
    }
    
    if(clearThread)
    {
        glh_job_clear_jobthread(thread);
    }
}
