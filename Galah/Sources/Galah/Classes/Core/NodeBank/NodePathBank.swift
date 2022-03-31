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
// NodePtrBank contains key value pairs of node id's to the actual pointer of the node.

internal struct NodePtrBank
{
    // Note that there's a trick in the hashing function of NodeID that means that nodeIDs hash just the raw id.
    var ptrBank = ContiguousDictionary<NodeID,Ptr<Node>>();
    
    subscript(nodeID: NodeID) -> Ptr<Node>
    {
        get
        {
            let nodeID = ptrBank[nodeID];
            assert(nodeID != nil, "The node you're requesting a path for doesn't exist!");
            return nodeID!;
        }
    }
    
    mutating func AddNode(nodeID: NodeID, nodePtr: Ptr<Node>)
    {
        let index = ptrBank.GetIndexForKey(nodeID);
        if( index == -1)
        {
            ptrBank[nodeID] = nodePtr;
            return;
        }
        
        assertionFailure("Tried to add a new nodePtr when one already exists! Update instead.");
    }
    
    mutating func UpdatePath(nodeID: NodeID, nodePtr: Ptr<Node>)
    {
        let index = ptrBank.GetIndexForKey(nodeID);

        if( index != -1)
        {
            let internalNodeID = ptrBank.GetKey(UInt(index))!;
            
            if(internalNodeID.reuseCounter < nodeID.reuseCounter )
            {
                ptrBank[nodeID] = nodePtr;
                return;
            }
            assertionFailure("The node you're trying to update is newer than the ID you're supplying.");
            return;
        }
        
        assertionFailure("Tried to update a nodePtr when it doesn't exist! Add instead.");
    }
    
    mutating func RemoveNode(nodeID: NodeID)
    {
        let index = ptrBank.GetIndexForKey(nodeID);

        if( index != -1)
        {
            ptrBank.RemoveKey(nodeID);
            return;
        }
        assertionFailure("Trying to remove a node path when none is associated with that index!");
    }
    
    
}
