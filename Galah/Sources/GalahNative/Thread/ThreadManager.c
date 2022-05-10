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

void glh_threadmanager_clearjoblist(GJobManagerJobList* jobList)
{
    jobList->capacity = 0;
    jobList->count = 0;
    jobList->jobBuffer = NULL;
}

bool glh_threadmanager_initjoblist(GJobManagerJobList* jobList)
{
    glh_threadmanager_clearjoblist(jobList);
    jobList->capacity = GALAH_THREAD_JOBBUFFER_SIZE;
    
    jobList->jobBuffer = glh_malloc(sizeof(GJob) * jobList->capacity);
    
    if(jobList->jobBuffer != NULL)
    {
        return true;
    }
    
    glh_threadmanager_clearjoblist(jobList);
    return false;
}

GJobID glh_threadmanager_initjob(GJobManagerJobList* jobList, const GJobData* jobData)
{
    GUInt16 listCount = glh_atomic_add_uint16(jobList->count, 1);
    GUInt16 listCapacity = glh_atomic_fetch_uint16(jobList->capacity);
    
    // We need to block here if the existing job buffer has run out. 
    while(listCount >= listCapacity)
    {
        listCapacity = glh_atomic_fetch_uint16(jobList->capacity);
        
        // It is this thread's job to grow the buffer. All other jobs stall.
        if(listCount == listCapacity)
        {
            GUInt16 newCapacity = listCapacity * 2;
            volatile GJob* oldBuffer = jobList->jobBuffer;
            
            volatile GJob* newBuffer = glh_malloc(sizeof(GJob) * newCapacity);

            glh_debug_assert(newBuffer != NULL);
            glh_memcpy((void*)newBuffer, (void*)oldBuffer, listCapacity);
            glh_atomic_set_ptr((GVolatileVoidPtr**)&jobList->jobBuffer, (GVolatileVoidPtr*)newBuffer);
            glh_atomic_set_uint16(jobList->capacity, newCapacity);
        }
    }
}

