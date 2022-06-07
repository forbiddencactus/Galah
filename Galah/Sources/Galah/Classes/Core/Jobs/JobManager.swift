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
// The JobManager is a manager for all scheduled jobs, allocated threads, etc.

import GalahNative.Hardware;
import GalahNative.Settings;
import GalahNative.Thread;

public struct JobManager
{
    // JobManager uses two circular buffers to achieve a lockless, non blocking, dyanmic job system.
    var jobBuffer = GJobBuffer(); // Circular buffer. Job threads execute jobs from here. Job thread adds jobs to here to dispatch.
    var dispatchedJobsBuffer = GJobBuffer(); // Newly dispatched jobs get added here.
    var dispatchedJobsOverflow = Array<Ptr<GJob>>(); // Job thread copies from dispatched buffer to here, if no free space on job buffer.
    var dispatchedDependentJobs = Array<Ptr<GJob>>(); // Jobs that are waiting on other jobs to dispatch.
    
    // This contains a pointer to a lockless, thread safe buffer where jobs are allocated.
    var jobManager: GJobManager = GJobManager();

    // Owned by Job Thread.
    var jobThread: GThread = GThread();
    var threadPool: ContiguousArray<JobThread>;
    var queuedJobs: Array<Ptr<Job>> = Array<Ptr<Job>>();
    
    private var JobThreadShouldBeActive: GVolatileBool = true;
    
    // The number of threads per processor. Changing this value changes the size of the thread pool.
    private var _threadsPerProcessor: GVolatileUInt32 = GVolatileUInt32(GALAH_THREAD_THREADCOUNTPERPROCESSOR);
    public var ThreadsPerProcessor: UInt
    {
        mutating get
        {
            return UInt(glh_atomic_fetch_uint32(&_threadsPerProcessor, GAtomicSeqCst));
        }
        // WARNING: Reducing this while there's active jobs on the fly can cause a big stall.
        set
        {
            glh_atomic_set_uint32(&_threadsPerProcessor, GUInt32(newValue),GAtomicSeqCst);
            
        }
    }
    
    // The active threads in your thread pool. Reduce this value to use less threads without having to discard them.
    private var _activeThreadCount = GVolatileUInt32(GALAH_THREAD_THREADCOUNTPERPROCESSOR);
    public var ActiveThreadCount: UInt32
    {
        mutating get
        {
            return UInt32(glh_atomic_fetch_uint32(&_activeThreadCount,GAtomicSeqCst));
        }
        set
        {
            if( newValue < glh_atomic_fetch_uint32(&_activeThreadCount,GAtomicSeqCst))
            {
                glh_atomic_set_uint32(&_activeThreadCount, GUInt32(newValue),GAtomicSeqCst);
            }
        }
    }
    
    // Thread safe. Runs the specified job. The job will execute when there's a free job thread to execute it.
    public mutating func DispatchJob(job: JobHandle)
    {
        if(job.IsValid)
        {
            
        }
    }
    
    // Unsafe, returns the job for jobID, if no such job exists this pointer will point to garbage. 
    internal func GetJobPtr(jobID: GJobID)
    {
        let selfPtr = unsafeBitCast(self, to: Ptr<JobManager>.self);
        glh_jobmanager_getjob(&selfPtr.pointee.jobManager, jobID);
    }
    
    // Returns the number of jobs spawned this frame, useful to check if a jobID is valid.
    internal func GetJobSpawnedCount() -> UInt16
    {
        let selfPtr = unsafeBitCast(self, to: Ptr<JobManager>.self);
        return glh_atomic_fetch_uint16(&selfPtr.pointee.jobManager.count, GAtomicSeqCst);
    }
    
    // Main Thread: Instantiates the JobManager.
    internal init()
    {
        threadPool = ContiguousArray<JobThread>();
        
        glh_job_clearjobbuffer(&jobBuffer);
        glh_job_clearjobbuffer(&dispatchedJobsBuffer);
        glh_jobmanager_initjobmanager(&jobManager);

        let threadPoolSize = GetThreadPoolSize();
        threadPool.reserveCapacity(threadPoolSize);
        
        for _ in 0..<threadPoolSize
        {
            threadPool.append(JobThread(jobBuffer: &jobBuffer));
        }
             
        let selfPtr = glh_pointer_get(&self);
        glh_thread_createthread(&jobThread, JobManagerThreadFuncEntry, selfPtr);
    }
    
    // JobManager Thread: Main thread for job manager.
    fileprivate mutating func JobManagerThread()
    {
        while(JobThreadShouldBeActive)
        {
            UpdateThreadPoolSize();
            PopDispatchBufferJobs();
            DispatchJobs();
            
        }
    }
    
    // Pops the jobs from the dispatch buffer onto the job buffer or the overflow array. Checks the jobs with dependencies.
    internal mutating func PopDispatchBufferJobs()
    {
        for i in (dispatchedDependentJobs.count - 1)...0
        {
            if(glh_jobmanager_jobdependenciescomplete(&jobManager, dispatchedDependentJobs[i].pointee.jobID))
            {
                dispatchedJobsOverflow.append(dispatchedDependentJobs.remove(at: i));
            }
        }
        
        var popJobs = true;
        while(popJobs)
        {
            let readIndex = glh_job_jobbuffer_increasereadindex(&dispatchedJobsBuffer);
            let jobToPop: Ptr<GJob>! = glh_job_jobbuffer_popjob(&dispatchedJobsBuffer, readIndex);
            
            if( jobToPop != nil)
            {
                if(glh_jobmanager_jobdependenciescomplete(&jobManager, jobToPop.pointee.jobID))
                {
                    dispatchedJobsOverflow.append(jobToPop);
                }
                else
                {
                    dispatchedDependentJobs.append(jobToPop);
                }
            }
            else
            {
                popJobs = false;
            }
        }
    }
    
    internal mutating func DispatchJobs()
    {
        var dispatchJobs = true;
        
        while(dispatchJobs)
        {
            dispatchJobs = glh_job_pushjob(&dispatchedJobsBuffer, dispatchedJobsOverflow.removeFirst());
        }
    }
    
    // Returns the size of the thread pool (processor count * threads per processor)
    internal mutating func GetThreadPoolSize() -> Int
    {
        return Int(glh_atomic_fetch_uint32(&_threadsPerProcessor,GAtomicSeqCst)) * Int(glh_hardware_getactiveprocessorcount());
    }
    
    //JobManager Thread: Updates the size of the thread pool.
    internal mutating func UpdateThreadPoolSize()
    {
        if(_threadsPerProcessor < _activeThreadCount)
        {
            _activeThreadCount = _threadsPerProcessor;
        }
        
        let threadPoolSize = GetThreadPoolSize();
        if(threadPoolSize > threadPool.count)
        {
            threadPool.reserveCapacity(threadPoolSize);
            for _ in 0..<(threadPoolSize - threadPool.count)
            {
                threadPool.append(JobThread(jobBuffer: &jobBuffer));
            }
        }
        else if(threadPoolSize < threadPool.count)
        {
            let beginOverflow = threadPool.count - threadPoolSize;
            for index in threadPool.count - 1 ... beginOverflow
            {
                let thread: Ptr<JobThread> = unsafeBitCast(threadPool[index], to: Ptr<JobThread>.self);
                if(thread.pointee.internalThread.gThread.isRunning)
                {
                    // Do stuff here?
                }
                
                threadPool.remove(at: index);
            }
        }
    }
}

fileprivate func JobManagerThreadFuncEntry(arg: VoidPtr?)
{
    let jobManager: Ptr<JobManager> = arg!.assumingMemoryBound(to: JobManager.self);
    
    jobManager.pointee.JobManagerThread();
}

fileprivate struct JobDependentJob
{
    let job: Ptr<GJob>;
    let dependentJobs = Array<GJobID>();
}
