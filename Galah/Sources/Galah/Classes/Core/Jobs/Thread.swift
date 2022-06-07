//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020, 2021, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// Our Thread type. 

import GalahNative.Thread;

internal struct JobThread: DeallocListener
{
    fileprivate static var jobThreadCount: GVolatileUInt8 = 0;
    var internalThread: GJobThread;
    private var deallocListener: DeallocBox<JobThread>? = nil;
    
    init(jobBuffer: Ptr<GJobBuffer>)
    {
        internalThread = GJobThread();
        glh_job_createjobthread(&internalThread, JobThreadFunc, jobBuffer);
        
        deallocListener = DeallocBox(self);
    }
    
    mutating func Wake()
    {
        glh_thread_wake(&internalThread.gThread);
    }
    
    mutating func Dealloc()
    {
        glh_job_killjobthread(&internalThread, true);
    }
    
}

fileprivate func JobThreadFunc(arg: VoidPtr?)
{
    let thread = arg!.assumingMemoryBound(to: GJobThread.self);

    let theJobThreadCount = glh_atomic_add_uint8(&JobThread.jobThreadCount,1,GAtomicSeqCst);
    
    glh_thread_rename("JobThread " + String(theJobThreadCount));
    
    while(!thread.pointee.shouldExit)
    {
        glh_thread_setrunning(true);
        
        if( glh_atomic_fetch_bool(&thread.pointee.shouldRun, GAtomicSeqCst))
        {
            let readIndex = glh_job_jobbuffer_increasereadindex(thread.pointee.jobBuffer);
            
            let jobToExecute: Ptr<GJob>! = glh_job_jobbuffer_popjob(thread.pointee.jobBuffer, readIndex);
            if( jobToExecute != nil)
            {
                if(glh_atomic_fetch_bool(&jobToExecute.pointee.isComplete,GAtomicSeqCst) == false)
                {
                    glh_thread_setthreaddata(jobToExecute.pointee.threadData); // Set the thread data.
                    jobToExecute.pointee.job.task(jobToExecute.pointee.job.taskDataExistentialContainer.0); // Run the job.
                    glh_atomic_set_bool(&jobToExecute.pointee.isComplete, true,GAtomicSeqCst); // Job has run, mark job complete.
                    jobToExecute.pointee.jobFinished.task(&jobToExecute.pointee.jobFinished.taskDataExistentialContainer); // Run callback.
                }

            }
            else
            {
                let writeIndex = glh_job_jobbuffer_getwriteindex(thread.pointee.jobBuffer);
                if(readIndex == writeIndex)
                {
                    glh_thread_setrunning(false);
                    glh_thread_sleep();
                }
            }
        }
        else
        {
            glh_thread_setrunning(false);
            glh_thread_sleep();
        }
    }
    
    return;
}
