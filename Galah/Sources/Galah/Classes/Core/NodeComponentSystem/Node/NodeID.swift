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
internal struct NodeID: Hashable
{
    internal let id: UInt32;
    internal let reuseCounter: UInt16; // The number of times this index has been reused.
    internal var metadata: NodeIDMetadata; // 8 bits of empty space for whatever.
    internal let componentIndex: UInt8; // Component header nodeIDs have this data to uniquely identify components.
    
    init()
    {
        id = UInt32.max;
        reuseCounter = UInt16.max;
        metadata = NodeIDMetadata();
        componentIndex = UInt8.max;
    }
    
    init(id: UInt32, reuseCounter: UInt16, componentIndex: UInt8, metadata: NodeIDMetadata)
    {
        self.id = id;
        self.reuseCounter = reuseCounter;
        self.metadata = metadata;
        self.componentIndex = componentIndex;
    }
    
    init(id: UInt32, reuseCounter: UInt16)
    {
        self.id = id;
        self.reuseCounter = reuseCounter;
        self.metadata = NodeIDMetadata();
        self.componentIndex = 0;
    }
    
    init(nodeID: NodeID, componentIndex: UInt8)
    {
        self.id = nodeID.id;
        self.reuseCounter = nodeID.reuseCounter;
        self.metadata = nodeID.metadata;
        self.componentIndex = componentIndex;
    }
    
    public func IsValid() -> Bool
    {
        if(id != UInt16.max)
        {
            return true;
        }
        
        return false;
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id);
    }
}

struct NodeIDMetadata: OptionSet
{
    let rawValue: UInt8
    
    static let Disabled = NodeIDMetadata(rawValue: 1 << 0);
}

// Same size as a pointer, but twice as useful!
struct NodeLocation
{
    let archetype: NodeArchetypeID
    let index: UInt32;
}
