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
// Nodes have Components that drive the Node's behaviour. 

import GalahNative.Types;
import GalahNative.Settings;

public protocol Component
{
    init() // Required by all structs that inherit from the Component protocol.
    
    /* ****************
    Activation & Deactivation...
    **************** */
    
    // Runs when the component is first attached to a node...
    func OnActivate()
    
    // Runs after OnActivate(), usually when the component will begin play.
    func OnBegin()
    
    // Runs when the component is being detached from a node...
    func OnDeactivate()
    
    /* ****************
    Archetype notifications...
    **************** */
    
    // Runs when the component's position in memory is about to change...
    func OnComponentPtrWillChange()
    
    // Runs when the component's position in memory changed...
    func OnComponentPtrDidChange()
    
    
}

public extension Component
{
    // Returns the component header for the node this component belongs to.
    internal func GetComponentHeader() -> ComponentHeader<Self>
    {
        let headerPtr: Ptr<ComponentHeader<Self>> = unsafeBitCast(self, to: Ptr<ComponentHeader<Self>>.self);
        //let nodeIDOffset: Int = MemoryLayout.offset(of: \ComponentHeader<Self>.nodeID)!;
        //let headerPtr: UnsafePointer<NodeID> = Cast( (componentPtr + nodeIDOffset) );
        #if GALAH_SAFEMODE
        if(headerPtr.pointee.headerKey != headerCheckTuple)
        {
            return ComponentHeader<Self>();
        }
        #endif
        return headerPtr.pointee;
    }
    
    // Calls the 'OnActivate' method and does a few safety checks first...
    internal func ActivateComponent()
    {
        #if GALAH_SAFEMODE
        if (self is AnyObject)
        {
            assertionFailure("Node components should only be structs!");
        }
        #endif
        
        self.OnActivate();
    }
    
    // Default implementations...
    init() { self.init(); }
    func OnActivate(){}
    func OnBegin(){}
    func OnDeactivate(){}
    func OnComponentPtrWillChange(){}
    func OnComponentPtrDidChange(){}
}
