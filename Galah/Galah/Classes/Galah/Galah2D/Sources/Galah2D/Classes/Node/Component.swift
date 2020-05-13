//
//  Component.swift
//  
//
//  Created by Alex Griffin on 13/5/20.
//

public protocol ComponentProtocol: AnyObject
{
    //Basic stuff
    func Construct();
    func Begin();
    func Tick();
    
    //Enable disable
    func OnEnable(willEnable: Bool);
}

public extension ComponentProtocol
{
    func Construct() {}
    func Begin() {}
    func Tick() {}
    func OnEnable(willEnable: Bool) {}
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
    
    //Please use Node.AddComponent unless you want to do fancy stuff. :)
    public required init() { }
    
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

