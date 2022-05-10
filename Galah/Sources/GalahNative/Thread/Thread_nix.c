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
// PThread implementation for Galah. For the unix systems!

#include "Thread/Thread.h"
#include "Thread/Atomic.h"
#include <pthread.h>
#include <unistd.h>

_Thread_local void* threadData = NULL;

void* glh_thread_rootthread(void* arg)
{
    GThread* thread = (GThread*)arg;
    glh_atomic_set_uint(thread->threadIndex, pthread_self());
    
    while(!thread->shouldExit)
    {
        
        glh_atomic_set_bool(thread->isRunning, true);

        GVolatileUInt rawReadIndex = glh_atomic_add_uint(thread->jobBuffer->readIndex, 1);
        GUInt readIndex = rawReadIndex % GALAH_THREAD_JOBBUFFER_SIZE;
        
        GJob* jobToExecute;
        glh_atomic_exchange_ptr((GVolatileVoidPtr**)&thread->jobBuffer->job[readIndex], NULL, (GVolatileVoidPtr**)&jobToExecute);
        if( jobToExecute != NULL)
        {
            threadData = jobToExecute->jobData.threadData; // Set the thread data.
            jobToExecute->jobData.job(jobToExecute->jobData.jobArg); // Run the job.
            glh_atomic_set_bool(jobToExecute->isComplete, true); // Job has run, mark job complete.
        }
        else
        {
            GVolatileUInt writeIndex = glh_atomic_fetch_uint32(thread->jobBuffer->writeIndex);
            if(readIndex == writeIndex)
            {
                glh_atomic_set_bool(thread->isRunning, false);
                pause();
            }
        }
    }
    glh_atomic_set_bool(thread->isRunning, false);

    // Thank you for flying with glh_thread. :)
    pthread_exit(NULL);
    return;
}

// Clears a thread struct clean.
void glh_thread_clear(GThread* thread)
{
    thread->nativethreadptr = NULL;
    thread->shouldExit = false;
    thread->isRunning = false;
    thread->threadIndex = 0;
    thread->jobBuffer = NULL;
}

// Clears the specified job data struct.
void glh_thread_job_cleardata(GJobData* jobData)
{
    jobData->job = NULL;
    jobData->jobFinishedCallback = NULL;
    jobData->jobArg = NULL;
    jobData->jobCallbackArg = NULL;
    jobData->threadData = NULL;

}

// Clears the specified job struct.
void glh_thread_job_clear(GJob* job)
{
    glh_thread_job_cleardata(&job->jobData);
    job->jobID = 0;
    job->isComplete = false;
}

// Clears the supplied job buffer.
void glh_thread_clearjobbuffer(GJobBuffer* jobBuffer)
{
    for(int i = 0; i < GALAH_THREAD_JOBBUFFER_SIZE; i++)
    {
        jobBuffer->job[i] = NULL;
    }
    
    jobBuffer->readIndex = 0;
    jobBuffer->writeIndex = 0;
}

// Returns an empty jobdata struct.
GJobData glh_thread_getemptydata()
{
    GJobData returnData;
    glh_thread_job_cleardata(&returnData);
    return returnData;
}

// Initialises the GThread pointed to by *thread. Thread will autosleep when it has no work.
int glh_thread_create(GThread* thread, GJobBuffer* jobBuffer)
{
    // Wipe our struct clean...
    glh_thread_clear(thread);
    
    thread->jobBuffer = jobBuffer;
    
    return pthread_create(thread->nativethreadptr, NULL, glh_thread_rootthread, (void*)thread);
}

// Sets the job to the specified thread and wakes the thread.
bool glh_thread_addjob(GThread* thread, GJob* job)
{
    if(thread->nativethreadptr != NULL && !thread->shouldExit)
    {
        GVolatileUInt rawWriteIndex = glh_atomic_add_uint(thread->jobBuffer->writeIndex, 1);
        GUInt writeIndex = rawWriteIndex % GALAH_THREAD_JOBBUFFER_SIZE;
        
        if(glh_atomic_fetch_ptr((GVolatileVoidPtr**)&thread->jobBuffer->job[writeIndex]) == NULL)
        {
            glh_atomic_set_ptr((GVolatileVoidPtr**)&thread->jobBuffer->job[writeIndex],job);
            
            // Wakey wakey.
            pthread_kill(thread->nativethreadptr, SIGCONT);
            return true;
        }
    }
    return false;
}

// Returns true if the thread has space in its job buffer for a job.
bool glh_thread_canaddjob(GThread* thread)
{
    GVolatileUInt rawWriteIndex = glh_atomic_fetch_uint(thread->jobBuffer->writeIndex);
    GUInt writeIndex = rawWriteIndex % GALAH_THREAD_JOBBUFFER_SIZE;

    if(glh_atomic_fetch_ptr((GVolatileVoidPtr**)&thread->jobBuffer->job[writeIndex]) == NULL)
    {
        return true;
    }
    
    return false;
}

// Gets the thread id of the thread this function is called from.
GThreadID glh_thread_getid()
{
    return pthread_self();
}

// Returns the pointer at _Thread_local void* threadData, which gets initialised from the Job data.
void* glh_thread_getthreaddata()
{
    return threadData;
}

// Kills the thread.
void glh_thread_killthread(GThread* thread, bool clearThread)
{
    if(thread->nativethreadptr != NULL)
    {
        thread->shouldExit = true;
        pthread_kill(thread->nativethreadptr, SIGCONT);
        
        // To avoid any drama, we'll wait for the thread to end before continuing...
        pthread_join(thread->nativethreadptr, NULL);
        
        // Sending signals to dead threads is undefined behaviour. Indicate the thread is gone. 
        thread->nativethreadptr = NULL;
    }
    
    if(clearThread)
    {
        glh_thread_clear(thread);
    }
}
