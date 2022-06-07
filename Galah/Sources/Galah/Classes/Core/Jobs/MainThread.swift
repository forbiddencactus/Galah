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
// Utilities to do with multithreading and the main thread.

import GalahNative.Thread;

public struct MainThread
{
    public static var sharedInstance: MainThread
    {
        get
        {
            return Director.sharedInstance.mainThread;
        }
    }
    public static let mainThreadID = glh_thread_getid();
    private static var enqueuedMainThreadTasks = Array<Task>();
    
    internal init() {}
}
