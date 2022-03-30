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
    name: String = "Node";
    
    //internal var
    //nodeIndex = NodeIndex();
    
    
    /*public var Transform: Transform
    {
        get { return _transform; }
    }*/
    
    internal var _depth: Int = 0;
    public var Depth: Int
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
    
    // Gets the pass this node belongs to.
    public func GetPassIndex() -> String
    {
        // Todo: fill out
        return "Default";
    }
    
    // Gets the subarchetype batch for this node.
    public func GetSubArchetypeBatchIndex() -> String
    {
        return "Default";
    }
    
    //public func AddComponent<T>() -> T where T: Component
    //{
        //let component: T = T();
        
        //component.Create(self);
        
        //_components.append(component);
        
        //return component;
    //}
    
    
    private mutating func SetNewDepth(newDepth: Int)
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
