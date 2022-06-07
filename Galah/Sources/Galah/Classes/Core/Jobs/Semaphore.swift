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
// Simple little semaphore.

import GalahNative.Thread;

internal struct Semaphore
{
    private var count: GVolatileUInt = 0;
    let max: UInt;
    
    init(_ max: UInt)
    {
        self.max = max;
    }
    
    public mutating func Enter()
    {
        var swapSuccess = false;
        while(!swapSuccess)
        {
            let oldCount = glh_atomic_fetch_uint(&count,GAtomicSeqCst);
            let newCount = oldCount + 1;
            if(newCount <= max)
            {
                swapSuccess = glh_atomic_compare_and_swap_uint(&count, oldCount, newCount,GAtomicSeqCst);
            }
        }
    }
    
    public mutating func Exit()
    {
        var swapSuccess = false;
        while(!swapSuccess)
        {
            let oldCount = glh_atomic_fetch_uint(&count,GAtomicSeqCst);
            let newCount = oldCount - 1;
            if(newCount < 0)
            {
                fatalError("Semaphore was exited more times than it was entered!");
            }
            
            swapSuccess = glh_atomic_compare_and_swap_uint(&count, oldCount, newCount,GAtomicSeqCst);
        }
    }
}
