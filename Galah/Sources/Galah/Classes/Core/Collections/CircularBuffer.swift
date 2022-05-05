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
// A circular buffer allocated on the heap containing elements of a particular type.

import GalahNative.Types;

internal struct CircularBuffer<T>
{
    
    // Circular buffer.
    let buffer: Ptr<T>;
    var readIndex: GVolatileUInt = 0;
    var writeIndex: GVolatileUInt = 0;
    
    init(capacity: UInt)
    {
        buffer = Ptr<T>.allocate(capacity: Int(capacity));
    }
    
    mutating func AddJob(_ job: Job)
    {
        
    }
    
    //mutating func GetJob() -> Job?

}
