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
// Wrapper around low level thread libraries, for use in our higher level threads/jobs.

#ifndef Thread_h
#define Thread_h
#include "GalahNative.h"

typedef GUInt GThreadID;
typedef void (*glh_thread_function)(void*);

typedef struct
{
    void* nativethreadptr; // Owned by thread.
    GVolatileBool isRunning; // Owned by thread.
    GVolatileUInt threadIndex; // Owned by thread. Set once during creation.
    glh_thread_function func;
    void* arg;
} GThread; 

// Clear thread. 
void glh_thread_clear(GThread* thread);

// Initialises the GThread pointed to by *thread. Thread will auto destroy when it returns.
int glh_thread_createthread(GThread* thread, glh_thread_function func, void* arg);

// Sends a wake signal to the specified sleeping thread. Returns true if success.
bool glh_thread_wake(GThread* thread);

// Sets the isRunning boolean in the thread you run this to the specified value.
void glh_thread_setrunning(bool isRunning);

// Sleeps the thread this function is executed on.
void glh_thread_sleep();

// Renames the thread with the specified name.
void glh_thread_rename(const char* threadName);

// Sets the thread data pointer for the thread this is called on to the specified pointer.
void glh_thread_setthreaddata(void* newThreadData);

// Gets the thread id of the thread this function is called from. 
GThreadID glh_thread_getid();

// Returns the pointer at _Thread_local void* threadData, which gets initialised from the Job data. 
void* glh_thread_getthreaddata();


#endif
