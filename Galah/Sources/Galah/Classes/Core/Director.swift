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
// Director is the root 'manager' singleton for the engine. 

import GalahNative.Types;
import GalahNative.Thread

public class Director
{
    public static let sharedInstance: Director = Director();
    public let mainThreadID = glh_thread_getid();
    
    // Frame Count
    private var _frameCount: GVolatileUInt32 = 0;
    public var FrameCount: UInt32
    {
        get { return _frameCount; }
    }
    
    
    // Node management...
    internal var nodeBank: NodeBank = NodeBank();
    internal var componentTypeBank: ComponentTypeBank = ComponentTypeBank();
    
    // Jobs
    internal var jobManager: JobManager = JobManager();
}
