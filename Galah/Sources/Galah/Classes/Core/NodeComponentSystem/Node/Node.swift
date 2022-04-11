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
// Nodes are the base object type that can be placed in scenes.

public struct Node
{
    public var
    Name: String = "Node";
    
    internal var _components: Array<Ptr<Component>>;
    
    internal var _nodeID: NodeID;
    public var NodeID: NodeID
    {
        get { return _nodeID; }
    }
    
    internal var _depth: UInt = 0;
    public var Depth: UInt
    {
        get { return _depth; }
        set(newDepth) { self.SetNewDepth(newDepth: newDepth); }
    }
    
    internal var _enabled: Bool = true;
    public var Enabled: Bool
    {
        get { return _enabled; }
        set(isEnabled) { self.SetEnabled(isEnabled: isEnabled)}
    }
    
    //public func AddComponent<T>() -> T where T: Component
    //{
        //let component: T = T();
        
        //component.Create(self);
        
        //_components.append(component);
        
        //return component;
    //}
    
    public func GetArchetypeTags() -> Array<ArchetypeTagKeyValuePair>
    {
        var returnArray = Array<ArchetypeTagKeyValuePair>();
        returnArray.append(ArchetypeTagKeyValuePair(key: NodeArchetypeTag.NodeDepth, value: String(_depth)));
        
        for componentPtr in _components
        {
            returnArray.append(contentsOf: componentPtr.pointee.GetArchetypeTags());
        }
        
        return returnArray;
    }
    
    // Initialises a node with the specified nodeID, list of pointers to its components, and name. 
    internal init(nodeID: NodeID, components: Array<Ptr<Component>>, name: String? = nil, depth: UInt = 0)
    {
        assert(nodeID.IsValid(), "You must initialise a node with a valid nodeID.");
        if(name == nil)
        {
            Name = "Node " + String(nodeID.id);
        }
        else
        {
            Name = name!;
        }
        
        _nodeID = nodeID;
        _components = components;
        _depth = depth;
    }
    
    
    
    private mutating func SetNewDepth(newDepth: UInt)
    {
        _depth = newDepth;
        // NodePool.sharedInstance.MarkDirty(node: self);
    }
        
    private mutating func SetEnabled(isEnabled: Bool)
    {
        _enabled = isEnabled;
        
        /*for component in components
        {
            component.OnEnable(willEnable: isEnabled);
        }*/
    }
}
