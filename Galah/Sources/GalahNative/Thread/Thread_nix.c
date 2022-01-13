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

void* glh_thread_rootthread(void* arg)
{
    GThread* thread = (GThread*)arg;
    
    while(!thread->shouldExit)
    {
        if(!thread->hasJob)
        {
            pause();
        }
        else
        {
            if(thread->job != NULL && thread->jobArg != NULL)
            {
                thread->job(thread->jobArg);
            }
            
            thread->job = NULL;
            thread->jobArg = NULL;
            
            glh_atomic_set_bool(thread->hasJob, false);
        }
    }
        
    // Thank you for flying with glh_thread. :)
    pthread_exit(NULL);
    return;
}

// Clears a thread struct clean.
void glh_thread_clear(GThread* thread)
{
    thread->nativethreadptr = NULL;
    thread->hasJob = false;
    thread->job = NULL;
    thread->shouldExit = false;
    thread->jobArg = NULL;
}

// Initialises the GThread pointed to by *thread. Thread will autosleep when it has no work.
int glh_thread_create(GThread* thread)
{
    // Wipe our struct clean...
    glh_thread_clear(thread);
    
    return pthread_create(thread->nativethreadptr, NULL, glh_thread_rootthread, (void*)thread);
}

// Sets the job to the specified thread and wakes the thread.
bool glh_thread_setjob(GThread* thread, glh_thread_function job, void* jobArg)
{
    if(thread->nativethreadptr != NULL && !thread->shouldExit)
    {
        
       if(glh_compare_and_swap_bool(thread->hasJob, false, true))
       {
            thread->job = job;
            thread->jobArg = jobArg;
            
            // Wakey wakey.
            // TODO: A job stack so we don't have to be waiting or sleeping the threads.
            pthread_kill(thread->nativethreadptr, SIGCONT);
            
            return true;
       }
    }
    
    return false;
}



// Kills the thread.
void glh_thread_killthread(GThread* thread)
{
    if(thread->nativethreadptr != NULL)
    {
        thread->shouldExit = true;
        pthread_kill(thread->nativethreadptr, SIGCONT);
        
        // To avoid any drama, we'll wait for the thread to end before continuing...
        pthread_join(thread->nativethreadptr, NULL);
    }
    
    glh_thread_clear(thread);
}
