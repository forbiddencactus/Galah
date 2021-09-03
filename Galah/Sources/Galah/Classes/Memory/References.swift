//---- Galah Engine---------------------------------------------------------//
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
// Manage Swift references. 


internal func retainObject(_ object: AnyObject)
{
    let ptr = GetPointerFromObject(object);
    ptr.assumingMemoryBound(to: ClassHeader.self).pointee.strongRetainCounts += 1;
}

// Note that this won't, as of yet, dealloc the object if you decrease the refcount.
// Also note you don't really wanna call this on manually allocated objects probably. 
internal func releaseObject(_ object: AnyObject)
{
    let ptr = GetPointerFromObject(object);
    ptr.assumingMemoryBound(to: ClassHeader.self).pointee.strongRetainCounts -= 1;
}
