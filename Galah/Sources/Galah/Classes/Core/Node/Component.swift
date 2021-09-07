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

typealias ComponentIndex = UInt8;
open class Component: GObject
{
    internal var
    nodeIndex = NodeIndex();
    
    internal var
    componentIndex: ComponentIndex = 0;
    
    internal var
    node: Node;
    
    public var Node: Node
    {
        get
        {
            return _node!;
        }
    }
    
    // Called the moment the component is active in the game.
    public func OnBegin() {}
    public func OnEnable(willEnable: Bool) {}
}
