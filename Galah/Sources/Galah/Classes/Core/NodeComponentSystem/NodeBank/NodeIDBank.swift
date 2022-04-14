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
// NodeIDBank provides reused or new node unique identifiers that are used to reference nodes. 

internal struct NodeIDBank
{
    var counter: UInt32 = 0;
    var idPool: Array<NodeID> = Array<NodeID>();
    
    // Gets a nodeID (either new or reused).
    mutating func Pop() -> NodeID
    {
        let returnCounter = counter;
        
        if (idPool.count > 0)
        {
            let nodeID = idPool.removeLast();
            let reuseCounter = nodeID.reuseCounter + 1
            
            // If we keep reusing the same id rapidly, we might eventually max out the reuse counter...
            if(reuseCounter < UInt16.max)
            {
                // We can reuse this id.
                return NodeID(id: nodeID.id, reuseCounter: reuseCounter);
            }
        }
        
        if(returnCounter >= UInt32.max)
        {
            fatalError("You created " + String(UInt32.max) + " unique nodes! Ima crash now. :(");
        }
        counter += 1;
        return NodeID(id: returnCounter, reuseCounter: 0);
    }
    
    // Push an unused nodeID in here so it gets reused when we next create a node.
    mutating func Push(nodeID: NodeID)
    {
        idPool.append(nodeID);
    }
}
