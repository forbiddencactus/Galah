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
_Thread_local GThread* currentThread = NULL;

void* glh_thread_rootthread(void* arg)
{
    currentThread = (GThread*)arg;
    glh_atomic_set_uint(currentThread->threadIndex, pthread_self(), GAtomicSeqCst);
    
    glh_thread_setrunning(true);

    currentThread->func(currentThread->arg);
    
    glh_thread_setrunning(false);

    // Thank you for flying with glh_thread. :)
    currentThread->nativethreadptr = NULL;
    pthread_exit(NULL);
}

void glh_thread_clear(GThread* thread)
{
    thread->nativethreadptr = NULL;
    thread->isRunning = false;
    thread->threadIndex = 0;
    thread->func = NULL;
    thread->arg = NULL;
}

// Initialises the GThread pointed to by *thread. Thread will auto destroy when it returns.
int glh_thread_createthread(GThread* thread, glh_thread_function func, void* arg)
{
    // Wipe our struct clean...
    glh_thread_clear(thread);
    
    thread->func = func;
    thread->arg = arg;
        
    return pthread_create((pthread_t _Nullable *)&thread->nativethreadptr, NULL, glh_thread_rootthread, (void*)thread);
}

// Sends a wake signal to the specified sleeping thread. Returns true if success.
bool glh_thread_wake(GThread* thread)
{
    if(thread->nativethreadptr != NULL)
    {
        // Wakey wakey.
        pthread_kill(thread->nativethreadptr, SIGCONT);
        return true;
    }
    
    return false;
}

// Sets the isRunning boolean in the thread you run this to the specified value.
void glh_thread_setrunning(bool isRunning)
{
    if( currentThread != NULL )
    {
        glh_atomic_set_bool(currentThread->isRunning, isRunning, GAtomicSeqCst);
    }
}

// Sleeps the thread this function is executed on.
void glh_thread_sleep()
{
    glh_thread_setrunning(false);
    pause();
}

// Renames the thread with the specified name.
void glh_thread_rename(const char* _Nonnull threadName)
{
    pthread_setname_np(threadName);
}

// Sets the thread data pointer for the thread this is called on to the specified pointer.
void glh_thread_setthreaddata(void* newThreadData)
{
    threadData = newThreadData;
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
