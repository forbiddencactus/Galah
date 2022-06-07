//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020 - 2022, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// IDBank provides generic reused or new unique identifiers.

import GalahNative.Types;
import GalahNative.Thread;

internal struct IDBank<T> where T: FixedWidthInteger
{
    private var counter: T = 0;
    private var idPool: Array<T> = Array<T>();
    
    // Gets a nodeID (either new or reused).
    mutating func Pop() -> T
    {
        let returnCounter = counter;
        
        if (idPool.count > 0)
        {
            return idPool.removeLast();
        }
        
        if(returnCounter >= T.max)
        {
            fatalError("You created " + String(T.max) + " unique ids! Ima crash now. :(");
        }
        
        counter += 1;
        return returnCounter;
    }
    
    // Push an unused nodeID in here so it gets reused when we next create a node.
    mutating func Push(id: T)
    {
        idPool.append(id);
    }
}

// Lockless version of IDBank. Basically a circular buffer using a 64 bit uint. When it overflows, it resets to 0.
internal struct LocklessIDBank
{
    private var counter: GVolatileUInt64 = 0;
    
    mutating func Pop() -> UInt64
    {
        return glh_atomic_add_uint64(&counter,1,GAtomicSeqCst);
    }
}

