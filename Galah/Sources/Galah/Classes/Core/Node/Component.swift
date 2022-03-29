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

fileprivate typealias HeaderCheckType = (UInt8, UInt8, UInt8, UInt8);
fileprivate let headerCheckTuple: HeaderCheckType  = ( 10, 50, 100, 159 );

internal struct ComponentHeader<T> where T: Component
{
    let nodeID: NodeID;
    var component: T;
    #if GALAH_SAFEMODE
    var headerKey: HeaderCheckType = headerCheckTuple;
    #endif
}

public protocol Component
{
}

extension Component
{
    // Returns the component header for the node this component belongs to.
    internal func GetComponentHeader() -> ComponentHeader<Self>
    {
        let componentPtr: UnsafeMutableRawPointer = unsafeBitCast(self, to: UnsafeMutableRawPointer.self);
        let componentOffset: Int = MemoryLayout.offset(of: \ComponentHeader<Self>.component)!;
        let headerPtr: UnsafePointer<ComponentHeader<Self>> = Cast( (componentPtr - componentOffset) );
        #if GALAH_SAFEMODE
        if(headerPtr.pointee.headerKey != headerCheckTuple)
        {
            return ComponentHeader<Self>();
        }
        #endif
        return headerPtr.pointee;
    }
}
