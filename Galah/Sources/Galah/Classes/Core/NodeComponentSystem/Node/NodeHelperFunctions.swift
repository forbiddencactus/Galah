//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2022, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// Node helper functions.

struct NodeHelpers
{
    static func GetNode(_ nodeID: NodeID) -> Ptr<Node>
    {
        return Director.sharedInstance.nodeBank.ptrBank.GetNode(nodeID: nodeID);
    }
    
    static func GetNodeExists(_ nodeID: NodeID) -> Bool
    {
        return Director.sharedInstance.nodeBank.ptrBank.GetNodeExists(nodeID: nodeID);
    }
    
    static func GetNodeData(_ nodeID: NodeID) -> Ptr<NodeData>
    {
        return Director.sharedInstance.nodeBank.ptrBank.GetNodeData(nodeID: nodeID);
    }
    
    static func GetComponentData(_ nodeID: NodeID) -> Ptr<ComponentData>
    {
        return Director.sharedInstance.nodeBank.ptrBank.GetComponentData(nodeID: nodeID);
    }
    
    static func GetNodeLocation(_ nodeID: NodeID) -> NodeLocation
    {
        return Director.sharedInstance.nodeBank.ptrBank.GetNodeLocation(nodeID: nodeID);
    }
}
