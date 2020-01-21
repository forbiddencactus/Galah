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
}

public protocol ComponentProtocol: AnyObject
{
    func Construct();
    func Begin();
    func Tick();
}

public extension ComponentProtocol
{
    func Construct() {}
    func Begin() {}
    func Tick() {}
}

open class _Component
{
    private var _node: Node? = nil;
    public var Node: Node
    {
        get
        {
            return _node!;
        }
    }
    
    //Try not to use this constructor, instead use Node.AddComponent. :)
    public required init() {}
    
    internal func Create(_ node: Node)
    {
        _node = node;
        
        guard let this = self as? ComponentProtocol else {
            return
        }
        
        this.Construct();
    }
        
    public var IsTicking: Bool
    {
        get
        {
            return false; //TODO: IMPLEMENT!
        }
    }
}

public typealias Component = _Component & ComponentProtocol;

