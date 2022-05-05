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
    // Owned by Job Thread.
    var threadPool: ContiguousArray<Thread>;
    var jobPool: ContiguousArray<Job>;
    var jobsInFlight: ContiguousArray<Job>;
    var completedJobs: ContiguousArray<Job>;
    var newJobBuffer: GJobManagerBuffer = GJobManagerBuffer();
    // End owned by Job Thread.
    
    private var JobThreadShouldBeActive: GVolatileBool = true;
    
    // The number of threads per processor. Changing this value changes the size of the thread pool.
    private var _threadsPerProcessor: GVolatileUInt32 = GVolatileUInt32(GALAH_THREAD_THREADCOUNTPERPROCESSOR);
    public var ThreadsPerProcessor: UInt
    {
        mutating get
        {
            return UInt(glh_atomic_fetch_uint32(&_threadsPerProcessor));
        }
        // WARNING: Reducing this while there's active jobs on the fly can cause a big stall.
        set
        {
            glh_atomic_set_uint32(&_threadsPerProcessor, GUInt32(newValue));
            
        }
    }
    
    // The active threads in your thread pool. Reduce this value to use less threads without having to discard them.
    private var _activeThreadCount = GVolatileUInt32(GALAH_THREAD_THREADCOUNTPERPROCESSOR);
    public var ActiveThreadCount: UInt32
    {
        mutating get
        {
            return UInt32(glh_atomic_fetch_uint32(&_activeThreadCount));
        }
        set
        {
            if( newValue < glh_atomic_fetch_uint32(&_activeThreadCount))
            {
                glh_atomic_set_uint32(&_activeThreadCount, GUInt32(newValue));
            }
        }
    }
    
    // Thread safe. Adds a job to the queue. This job will be added onto a thread's job queue and executed when the thread gets to it.
    public mutating func AddJob(job: Job) -> Job.JobID
    {
        return Job.JobID.max;
    }
    
    // Main Thread: Instantiates the JobManager.
    internal init()
    {
        threadPool = ContiguousArray<Thread>();
        jobPool = ContiguousArray<Job>();
        jobsInFlight = ContiguousArray<Job>();
        completedJobs = ContiguousArray<Job>();


        
        let threadPoolSize = GetThreadPoolSize();
        threadPool.reserveCapacity(threadPoolSize);
        jobsInFlight.reserveCapacity(threadPoolSize);
        jobPool.reserveCapacity(threadPoolSize);
        
        for _ in 0..<threadPoolSize
        {
            threadPool.append(Thread());
        }        
    }
    
    // JobManager Thread: Main thread for job manager.
    private mutating func JobManagerThread()
    {
        while(JobThreadShouldBeActive)
        {
            UpdateThreadPoolSize();
        }
    }
    
    // Returns the size of the thread pool (processor count * threads per processor)
    internal mutating func GetThreadPoolSize() -> Int
    {
        return Int(glh_atomic_fetch_uint32(&_threadsPerProcessor)) * Int(glh_hardware_getactiveprocessorcount());
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
                threadPool.append(Thread());
            }
        }
        else if(threadPoolSize < threadPool.count)
        {
            for index in (threadPool.count - threadPoolSize)..<(threadPool.count - 1)
            {
                var thread: Ptr<Thread> = unsafeBitCast(threadPool[index], to: Ptr<Thread>.self);
                if(thread.pointee.internalThread.isRunning)
                {
                    // We need to rescue any enqueued jobs before we wipe the thread.
                    
                    // Kill the thread without wiping it.
                    // This will stall this thread while it waits for its last job to complete.
                    glh_thread_killthread(&thread.pointee.internalThread, false);
                    
                    // At this point the thread should be merged in. Any data left in the job buffers can be considered unprocessed.
                    for index in 0..<Int(GALAH_THREAD_JOBBUFFER_SIZE)
                    {
                        let jobBuffer: Ptr<Ptr<GJob>> = unsafeBitCast(thread.pointee.internalThread.jobBuffer.job, to: Ptr<Ptr<GJob>>.self);
                        let jobID = jobBuffer.advanced(by: index).pointee.pointee.jobID;
                        
                        assertionFailure(); // Todo finish. 
                    }
                    
                }
            }
        }
    }
    
}
