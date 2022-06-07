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
// Utility to access array[array] arrays, especially if statically declared.

import GalahNative.Settings;

internal struct StaticBuffer<T>
{
    let staticBuffer: UnsafeMutablePointer<T>;
    #if GALAH_SAFEMODE
    let capacity: UInt64;
    #endif
    
    
    subscript(index: Int) -> T
    {
            get
            {
                #if GALAH_SAFEMODE
                assert(index < capacity, "Out of bounds!");
                #endif

                return (staticBuffer + index).pointee;
            }
            set(newElement)
            {
                #if GALAH_SAFEMODE
                assert(index < capacity, "Out of bounds!");
                #endif
                
                (staticBuffer + index).pointee = newElement;
            }
    }
    
    init(staticbuffer: UnsafeMutableRawPointer, capacity: UInt64)
    {
        self.staticBuffer = staticbuffer.assumingMemoryBound(to: T.self);
        
        #if GALAH_SAFEMODE
        self.capacity = capacity;
        #endif
    }
}
