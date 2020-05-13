//
//  Node.swift
//  Galah
//
//  Created by Alex Griffin on 31/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

open class Node
{
    private var _transform: Transform!;
    private var _components: Array<Component>
    
    public var Transform: Transform
    {
        get { return _transform; }
    }
    
    private var _depth: Int = 0;
    public var Depth: Int
    {
        get { return _depth; }
        set(newDepth) { self.SetNewDepth(newDepth: newDepth); }
    }
    
    private var _enabled: Bool = true;
    public var Enabled: bool
    {
        get { return _enabled; }
        set(isEnabled) {}
    }
    
    public init()
    {
        _components = Array<Component>();
        _transform = AddComponent();
    }
    
    public func AddComponent<T>() -> T where T: Component
    {
        let component: T = T();
        
        component.Create(self);
        
        _components.append(component);
        
        return component;
    }
    
    
    private func SetNewDepth(newDepth: Int)
    {
        for component in _components
        {
            if let renderComponent = component as? RenderComponent
            {
                renderComponent.DepthWillChange(oldDepth:_depth, newDepth:newDepth);
            }
        }
        _depth = newDepth;
    }
        
    private func SetEnabled(isEnabled: Bool)
    {
        _enabled = isEnabled;
        
        for component in _components
        {
            component.OnEnable(willEnable: isEnabled);
        }
    }
}
