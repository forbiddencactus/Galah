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

internal struct Thread: DeallocListener
{
    var internalThread: GThread;
    private var deallocListener: DeallocBox<Thread>? = nil;
    
    init(jobBuffer: Ptr<GJobBuffer>)
    {
        internalThread = GThread();
        glh_thread_create(&internalThread, jobBuffer);
        
        deallocListener = DeallocBox(self);
    }
    
    internal mutating func AddJob(job: inout Job) -> Bool
    {
        return glh_thread_addjob(&internalThread, &job.job);
    }
    
    mutating func Dealloc()
    {
        glh_thread_killthread(&internalThread, true);
    }
    
}
