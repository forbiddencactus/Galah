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
// Node IDs, paths, and such things.

// Unique id for a node. Packed into a convenient word sized package!
public struct NodeID: Hashable
{
    internal let id: UInt32;
    internal let reuseCounter: UInt16; // The number of times this index has been reused.
    internal let componentIndex: UInt8; // The index of the component we're pointing to, if we're pointing to one. Otherwise, 0.
    internal let metadata: UInt8; // ??? 8 bits of empty space for whatever.
    
    init()
    {
        id = UInt32.max;
        componentIndex = UInt8.max;
        reuseCounter = UInt16.max;
        metadata = UInt8.max;
    }
    
    init(id: UInt32, reuseCounter: UInt16, componentIndex: UInt8, metadata: UInt8)
    {
        self.id = id;
        self.reuseCounter = reuseCounter;
        self.componentIndex = componentIndex;
        self.metadata = metadata;
    }
    
    init(id: UInt32, reuseCounter: UInt16)
    {
        self.id = id;
        self.reuseCounter = reuseCounter;
        self.componentIndex = 0;
        self.metadata = 0;
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id);
    }
}
