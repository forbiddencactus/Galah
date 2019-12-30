//
//  Node.swift
//  Galah
//
//  Created by Alex Griffin on 31/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

public class Node
{
    private var _transform: Transform = Transform(self);
    private var _components: Array<Component>
    
    public init()
    {
        _components = Array<Component>();
        _components.append(_transform);
    }
    
    public func AddComponent<T>() -> T where T: Component
    {
        let component: T = T(self);
        
        _components.append(component);
        
        return component;
    }
}

public class Component
{
    private var _node: Node;
    public var Node: Node
    {
        get
        {
            return _node;
        }
    }
    
    internal required init(_ node: Node)
    {
        _node = node;
    }
    
    
}
