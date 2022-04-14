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
    var locationBank = ContiguousDictionary<NodeID,NodeLocation>();
    let defaultNode: Node = Node();
    
    func GetNodeExists(nodeID: NodeID) -> Bool
    {
        let index = locationBank.GetIndexForKey(nodeID);
        if(index >= 0)
        {
            let key = locationBank.GetKey(UInt(index));
            
            if(key!.reuseCounter == nodeID.reuseCounter)
            {
                return true;
            }
        }
        
        return false;
    }
    
    mutating func AddNode(nodeID: NodeID, nodeLocation: NodeLocation)
    {
        let index = locationBank.GetIndexForKey(nodeID);
        if( index == -1)
        {
            locationBank[nodeID] = nodeLocation;
            return;
        }
        
        assertionFailure("Tried to add a new nodePtr when one already exists! Update instead.");
    }
    
    func GetNode(nodeID: NodeID) -> Ptr<Node>
    {
        if(GetNodeExists(nodeID: nodeID))
        {
            let location = locationBank[nodeID]!;
            
            let archetype = Director.sharedInstance.nodeBank.archetypeStore.GetArchetype(archetypeID: location.archetype);
            return archetype.pointee.GetNode(index: location.index);
        }
        
        assertionFailure("Node does not exist or nodeID reference is old!");
        let thereturn = Ptr<Node>(nil);
        return thereturn!;
    }
    
    func GetNodeData(nodeID: NodeID) -> Ptr<NodeData>
    {
        if(GetNodeExists(nodeID: nodeID))
        {
            let location = locationBank[nodeID]!;
            
            let archetype = Director.sharedInstance.nodeBank.archetypeStore.GetArchetype(archetypeID: location.archetype);
            return archetype.pointee.GetNodeData(index: location.index);
        }
        
        assertionFailure("Node does not exist or nodeID reference is old!");
        let thereturn = Ptr<NodeData>(nil);
        return thereturn!;
    }
    
    mutating func UpdatePath(nodeID: NodeID, nodeLocation: NodeLocation)
    {
        let index = locationBank.GetIndexForKey(nodeID);

        if( index != -1)
        {
            let internalNodeID = locationBank.GetKey(UInt(index))!;
            
            if(internalNodeID.reuseCounter < nodeID.reuseCounter )
            {
                locationBank[nodeID] = nodeLocation;
                return;
            }
            assertionFailure("The node you're trying to update is newer than the ID you're supplying.");
            return;
        }
        
        assertionFailure("Tried to update a nodePtr when it doesn't exist! Add instead.");
    }
    
    mutating func RemoveNode(nodeID: NodeID)
    {
        let index = locationBank.GetIndexForKey(nodeID);

        if( index != -1)
        {
            locationBank.RemoveKey(nodeID);
            return;
        }
        assertionFailure("Trying to remove a node path when none is associated with that index!");
    }
    
    
}
