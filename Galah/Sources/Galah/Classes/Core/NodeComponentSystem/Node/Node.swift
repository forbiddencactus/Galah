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
// Nodes are the base object type that can be placed in scenes.

internal struct NodeData
{
    var Name: String = "Node";
    var Components = Array<Ptr<Component>>();
    var Depth: UInt = 0;
}

public struct Node
{
    internal var _nodeID: NodeID;
    
    public var Depth: UInt
    {
        get { return GetDepth(); }
        set(newDepth) { self.SetNewDepth(newDepth: newDepth); }
    }
    
    // Set thru NodeID metadata. 
    public var Enabled: Bool
    {
        get { return !GetEnabled(); }
        set(isEnabled) { self.SetEnabled(isEnabled: isEnabled)}
    }
    
    //public func AddComponent<T>() -> T where T: Component
    //{
        //let component: T = T();
        
        //component.Create(self);
        
        //_components.append(component);
        
        //return component;
    //}
    

    internal init()
    {
        _nodeID = NodeID();
    }
    
    // Initialises a node with the specified nodeID, list of pointers to its components, and name. 
    internal init(nodeID: NodeID)
    {
        assert(nodeID.IsValid(), "You must initialise a node with a valid nodeID.");
        _nodeID = nodeID;
    }
    
    
    private func GetDepth() -> UInt
    {
        return NodeHelpers.GetNodeData(_nodeID).pointee.Depth;
    }
    
    private mutating func SetNewDepth(newDepth: UInt)
    {
        NodeHelpers.GetNodeData(_nodeID).pointee.Depth = newDepth;
        Director.sharedInstance.nodeBank.MarkDirty(nodeID: _nodeID);
    }
    
    private func GetEnabled() -> Bool
    {
        return !NodeHelpers.GetNode(_nodeID).pointee._nodeID.metadata.contains(.Disabled);
    }
    
    private func SetEnabled(isEnabled: Bool)
    {
        NodeHelpers.GetNode(_nodeID).pointee.SetEnabledInternal(isEnabled: isEnabled);
    }
        
    private mutating func SetEnabledInternal(isEnabled: Bool)
    {
        if(!isEnabled)
        {
            _nodeID.metadata.insert(.Disabled);
        }
        else
        {
            _nodeID.metadata.remove(.Disabled);
        }
    }
}

