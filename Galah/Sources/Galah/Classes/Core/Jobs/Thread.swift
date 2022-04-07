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

public final class Thread: GObject
{
    private var internalThread: GThread = GThread();
    
    //public var HasJob: Bool { get { return internalThread.hasJob; }}
    
    /*public override func OnConstruct()
    {
        if(glh_thread_create(&internalThread) != 0)
        {
            // error here, todo.
        }
    }*/
    
    public func AddJob(job: @escaping (Any) ->(), jobArg: Any) -> Bool
    {
        return glh_thread_addjob(&internalThread, unsafeBitCast(job, to: glh_thread_function?.self), unsafeBitCast(jobArg, to: VoidPtr.self));
    }
    /*
    deinit()
    {
        glh_thread_killthread(&internalThread);
    }
 */
}
