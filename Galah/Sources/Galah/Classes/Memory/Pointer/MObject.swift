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
// A manually allocated object. Yours to go nuts with.

import GalahNative;

internal class MObject
{
    // Construct the specified MObject into the specified pointer. This object's retain count will be increased by 1.
    @discardableResult
    internal static func Construct<T>(_ ptr: Ptr<T>) -> T? where T: MObject
    {
        return unsafeBitCast(MObject.Construct(type: T.self, ptr: Cast(ptr)), to: T.self);
    }
    
    // Construct into the specified pointer. This object's retain count will be increased by 1.
    @discardableResult
    internal static func Construct(type: MObject.Type, ptr: Ptr<VoidPtr>) -> MObject?
    {
        // I couldn't figure out how to get placement new working without a copy like the one that's happening here.
        // galah_placementNew lays out the instance just fine, but I haven't figured out how to run the initialiser for it. :P
        // So we'll just have to live with this less than ideal method for now.

        // Our less than ideal method...
        let copyFrom = type.init();
        var constr = try! unsafeBitCast(galah_placementNew(type: type, ptr: ptr), to: MObject.self);

        // Increase the ref count once...
        // TODO: It seems our instance by default already has a strong retain?
        //_ = Unmanaged.passRetained(constr);
        
        // We need to copy all the properties from our copyFrom class into our constructed class, so as to play nice with ARC and avoid dangling pointers.
        let info = try! typeInfo(of: type);
        for property in info.properties
        {
            try! property.set(value: property.get(from: copyFrom), on: &constr);
        }
                
        // Return. copyFrom should also get released here. Waste of an alloc, really want to optimise this, but it works!
        return constr;
    }
        
    // BIG NOTE: Unfortunately I couldn't (yet) figure out a way to run init() using our custom allocation stuff.
    internal required init()
    {
    }
    
    deinit
    {
    }
}
