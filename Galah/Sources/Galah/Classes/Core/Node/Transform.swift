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
// Transforms contain information about the Node's position in the Scene.

public class Transform: Component
{
    private var _parent: Transform? = nil;
    public var Parent: Transform?
    {
        get
        {
            return _parent;
        }
        
        set(newParent)
        {
            self.SetParent(parent: newParent);
        }
    }
    
    private var _children: Array<Transform> = Array<Transform>();
    
    public func Construct()
    {
        //self.InternalWorldRefresh();
    }
    
    public func SetParent(parent: Transform?, keepWorldPosition: Bool = true)
    {
    }
}

