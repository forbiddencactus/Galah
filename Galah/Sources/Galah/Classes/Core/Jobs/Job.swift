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
// Jobs can be scheduled to run on separate threads through the JobManager.

import GalahNative.Thread;

public struct JobHandle
{
    let jobID: GJobID;
    let frameNumber: UInt32;
    
    public var IsValid: Bool
    {
        get
        {
            let frameCount = Director.sharedInstance.FrameCount;
            let jobCount = Director.sharedInstance.jobManager.GetJobSpawnedCount();
            if ( (frameNumber == frameCount) && (jobID < jobCount))
            {
                return true;
            }
            return false;
        }
    }
}

internal struct Job
{
    typealias Function = glh_thread_function;
    typealias CompletionCallback = glh_job_callback;
    
    var job: GJob;
        
    internal init(job: GJob)
    {
        self.job = job;
    }
}
