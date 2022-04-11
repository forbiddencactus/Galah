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
// ComponentHeader wraps components in the NodeBank to store runtime data. 

fileprivate typealias HeaderCheckType = (UInt8, UInt8, UInt8, UInt8);
fileprivate let headerCheckTuple: HeaderCheckType  = ( 10, 50, 100, 159 );

internal protocol PComponentHeader
{
    func GetType() -> Component.Type;
    func GetNodeID() -> NodeID;
    mutating func GetPtr() -> VoidPtr;
}

internal struct ComponentHeader<T>: PComponentHeader where T: Component
{
    var component: T;
    let nodeID: NodeID;
    #if GALAH_SAFEMODE
    var headerKey: HeaderCheckType = headerCheckTuple;
    #endif
    
    init(nodeID: NodeID)
    {
        self.nodeID = nodeID;
        self.component = T();
    }
    
    init(nodeID: NodeID, component: T)
    {
        self.nodeID = nodeID;
        self.component = component;
    }
    
    func GetType() -> Component.Type
    {
        return T.self;
    }
    
    func GetNodeID() -> NodeID
    {
        return nodeID;
    }
    
    mutating func GetPtr() -> VoidPtr
    {
        return Cast(&self);
    }
}
