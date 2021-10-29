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
// An object which is manually managed by the Galah engine. Base object for most Galah things.

import GalahNative;

internal typealias GIndex = UInt64;

open class GObject
{
    private static var objectIndexCount: GVolatileUInt64 = 0;
    internal var objectIndex: GIndex = GIndex.max;
        
    // Construct an instance of the specified GObject.
    internal static func Construct<T>() -> T? where T: GObject
    {
        return GObject.Construct(type: T.self) as? T;
    }
    
    // Construct into the specified pointer. This object's retain count will be increased by 1.
    @discardableResult
    internal static func Construct<T>(_ ptr: Ptr<T>) -> T? where T: GObject
    {
        return unsafeBitCast(GObject.Construct(type: T.self, ptr: ptr.GetVoidPtr()), to: T.self);
    }
    
    internal static func Construct(type: GObject.Type) -> GObject?
    {
        let constr = type.init();
        return constr;
    }
    
    // Construct into the specified pointer. This object's retain count will be increased by 1.
    @discardableResult
    internal static func Construct(type: GObject.Type, ptr: Ptr<VoidPtr>) -> GObject?
    {
        // I couldn't figure out how to get placement new working without a copy like the one that's happening here.
        // galah_placementNew lays out the instance just fine, but I haven't figured out how to run the initialiser for it. :P
        // So we'll just have to live with this less than ideal method for now.
       /* do
        {
            constr = try unsafeBitCast(galah_placementNew(type: type, ptr: ptr), to: GObject.self);
            //constr.internallyConstructed = true;
            
            // run our fake init
            constr.internalConstructor();
        }
        catch
        {
            return nil;
        }
        
        retainObject(constr);*/
        
        // Our less than ideal method...
        let constr = type.init();
        let extents = ExtentsOf(constr);
        
        // Increase the ref count once...
        let garbage = Unmanaged.passRetained(constr);
        
        // Copy the object into our buffer...
        let newRawRef = glh_memcpy(ptr.raw, Cast(constr), extents);
        
        var retRef: GObject? = nil;
        
        // Mark a copy here in the hopes ARC doesn't destroy our copied data when we go on to release the original object...
        retRef = Cast(galah_copyValue(dest: Ptr<VoidPtr>(&retRef), source: Ptr<VoidPtr>(newRawRef!), type: type));
        
        // Release the original object...
        garbage.release();
        
        // Return.
        return retRef;
    }
        
    
    // BIG NOTE: Unfortunately I couldn't (yet) figure out a way to run init() using our custom allocation stuff.
    public required init()
    {
        objectIndex = glh_atomic_add_uint64(&GObject.objectIndexCount, 1);
    }
    
    deinit
    {
    }
}

public enum GObjectError: Error
{
    // GObjects are manually managed by the engine. You can't construct them yourself!
    case NotProperlyConstructed;
    case AllocError;
}
