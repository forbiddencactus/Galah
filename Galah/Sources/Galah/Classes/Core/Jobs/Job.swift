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
// Jobs can be scheduled to run on separate threads through the JobPool.

import GalahNative.Thread;

public struct Job
{
    private static var idBank = LocklessIDBank();

    public typealias JobID = UInt64;
    public typealias Function = glh_thread_function;
    public typealias CompletionCallback = (JobID) -> ();
    
    var job: GJob;
        
    public init(function: @escaping Job.Function, jobArg: VoidPtr?, threadData: VoidPtr? = nil)
    {
        let id = Job.idBank.Pop();
        job = GJob(job: function, jobArg: jobArg, threadData: threadData, jobID: id, isComplete: false);
    }
}
