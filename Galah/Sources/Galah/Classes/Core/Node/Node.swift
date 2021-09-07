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

public class Node: GObject
{
    public var
    name: String = "Node";
    
    internal var
    nodeIndex = NodeIndex();
    
    internal var
    components = Array<Component>();
    
    public var Transform: Transform
    {
        get { return _transform; }
    }
    
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
    
    public required init()
    {
        _components = Array<Component>();
        //_transform = AddComponent();
    }
    
    //public func AddComponent<T>() -> T where T: Component
    //{
        //let component: T = T();
        
        //component.Create(self);
        
        //_components.append(component);
        
        //return component;
    //}
    
    
    private func SetNewDepth(newDepth: Int)
    {

        _depth = newDepth;
    }
        
    private func SetEnabled(isEnabled: Bool)
    {
        _enabled = isEnabled;
        
        for component in components
        {
            component.OnEnable(willEnable: isEnabled);
        }
    }
}
