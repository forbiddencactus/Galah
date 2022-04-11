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

typealias JobFunction = glh_thread_function;

public struct Job
{
    var job: GJob;
    
    init(function: @escaping JobFunction, jobArg: Any)
    {
        job = GJob(job: function, jobArg: unsafeBitCast(jobArg, to: VoidPtr.self), isComplete: false);
    }
}
