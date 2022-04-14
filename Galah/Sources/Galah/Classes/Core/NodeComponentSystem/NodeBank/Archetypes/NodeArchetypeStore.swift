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
// The Archetype Store is used to store and get node archetypes. 

import GalahNative.Settings;

typealias NodeArchetypeID = UInt32;
internal struct NodeArchetypeStore
{
    internal var archetypeIDCount: NodeArchetypeID = 0;
    internal var nodeArchetypes = ContiguousDictionary<NodeArchetypeID,NodeArchetype>();
    internal var transientNodes = Array<Node>();
    internal var transientComponents = ContiguousDictionary<ComponentType,Buffer<Component>>();
    internal var transientNodeList = Array<NodeID>();
    
    func GetArchetype(archetypeID: NodeArchetypeID) -> Ptr<NodeArchetype>
    {
        let archetype = nodeArchetypes.GetValuePtr(archetypeID);
        assert(archetype != nil, "Archetype is nil, wrong archetype ID!");
        
        return archetype!;
    }
    
    mutating func CreateArchetype() -> NodeArchetypeID
    {
        let returnID = archetypeIDCount;
        archetypeIDCount += 1;
        nodeArchetypes[returnID] = NodeArchetype(archetypeID: returnID);
        return returnID
    }
}
