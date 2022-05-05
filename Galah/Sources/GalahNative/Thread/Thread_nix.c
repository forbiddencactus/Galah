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
        GVolatileUInt readIndex = glh_atomic_fetch_uint(thread->jobBuffer.readIndex);
        
        if( thread->jobBuffer.job[readIndex] != NULL)
        {
            threadData = thread->jobBuffer.job[readIndex]->threadData; // Set the thread data. 
            thread->jobBuffer.job[readIndex]->job(thread->jobBuffer.job[readIndex]->jobArg);
            
            thread->jobBuffer.job[readIndex]->isComplete = true;
            thread->jobBuffer.job[readIndex] = NULL;
            
            if( readIndex < (GALAH_THREAD_JOBBUFFER_SIZE - 1))
            {
                glh_atomic_set_uint(thread->jobBuffer.readIndex, readIndex + 1);
            }
            else
            {
                glh_atomic_set_uint(thread->jobBuffer.readIndex, 0);
            }
        }
        else
        {
            GVolatileUInt writeIndex = glh_atomic_fetch_uint(thread->jobBuffer.writeIndex);
            if(readIndex == writeIndex)
            {
                glh_atomic_set_bool(thread->isRunning, false);
                pause();
            }
            else
            {
                log_warning("Thread %d found null job at position %d in circular buffer.", thread->threadIndex, readIndex);
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
    
    for(int i = 0; i < GALAH_THREAD_JOBBUFFER_SIZE; i++)
    {
        thread->jobBuffer.job[i] = NULL;
    }
    
    thread->jobBuffer.readIndex = 0;
    thread->jobBuffer.writeIndex = 0;
}

// Initialises the GThread pointed to by *thread. Thread will autosleep when it has no work.
int glh_thread_create(GThread* thread)
{
    // Wipe our struct clean...
    glh_thread_clear(thread);
    
    return pthread_create(thread->nativethreadptr, NULL, glh_thread_rootthread, (void*)thread);
}

// Sets the job to the specified thread and wakes the thread.
bool glh_thread_addjob(GThread* thread, GJob* job)
{
    if(thread->nativethreadptr != NULL && !thread->shouldExit)
    {
        GVolatileUInt writeIndex = glh_atomic_fetch_uint(thread->jobBuffer.writeIndex);
        
        if(thread->jobBuffer.job[writeIndex] == NULL)
        {
            thread->jobBuffer.job[writeIndex] = job;
            
            if( writeIndex < (GALAH_THREAD_JOBBUFFER_SIZE - 1))
            {
                glh_atomic_set_uint(thread->jobBuffer.writeIndex, writeIndex + 1);
            }
            else
            {
                glh_atomic_set_uint(thread->jobBuffer.writeIndex, 0);
            }
            
            // Wakey wakey.
            // TODO: Check there's no chance the thread can be left sleeping for some reason?
            //if(!glh_atomic_fetch_bool(thread->isRunning))
            //{
                pthread_kill(thread->nativethreadptr, SIGCONT);
            //}
            return true;
        }
    }
    return false;
}

// Returns true if the thread has space in its job buffer for a job.
bool glh_thread_canaddjob(GThread* thread)
{
    GVolatileUInt writeIndex = glh_atomic_fetch_uint(thread->jobBuffer.writeIndex);
    if(thread->jobBuffer.job[writeIndex] == NULL)
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
