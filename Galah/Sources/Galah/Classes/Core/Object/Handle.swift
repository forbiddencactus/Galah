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
// A 'smart pointer' that points to an object irregardless of where it gets shuffled to in memory.

import GalahNative.Types;

public struct Hnd<T> where T: NodePoolObject
{
    private let handleIndex: NodeIndex;
    
    public unowned(unsafe) var ref: T?
    {
        get
        {
            return nil;
        }
    }
    
    internal init(handleIndex: NodeIndex)
    {
        self.handleIndex = handleIndex;
    }
}


