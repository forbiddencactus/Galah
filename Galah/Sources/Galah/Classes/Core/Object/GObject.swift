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
    
    public func OnConstruct() {}
    
    // Construct an instance of the specified GObject.
    internal static func Construct<T>() -> T? where T: GObject
    {
        return GObject.Construct(type: T.self) as? T;
    }
    
    // Construct into the specified pointer.
    @discardableResult
    internal static func Construct<T>(_ ptr: Ptr<T>) -> T? where T: GObject
    {
        return unsafeBitCast(GObject.Construct(type: T.self, ptr: ptr.GetVoidPtr()), to: T.self);
    }
    
    internal static func Construct(type: GObject.Type) -> GObject?
    {
        let constr: GObject;

        do
        {
            constr = try unsafeBitCast(buildClass(type: type), to: GObject.self);
            //constr.internallyConstructed = true;
            
            // run our fake init
            constr.internalConstructor();
        }
        catch
        {
            return nil;
        }
        
        retainObject(constr);
                
        return constr;
    }
    
    @discardableResult
    internal static func Construct(type: GObject.Type, ptr: Ptr<VoidPtr>) -> GObject?
    {
        let constr: GObject;
        do
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
        
        retainObject(constr);
                
        return constr;
    }
        
    
    // BIG NOTE: Unfortunately I couldn't (yet) figure out a way to run init() using our custom allocation stuff.
    private init() throws
    {
        throw GObjectError.NotProperlyConstructed;
    }
    
    private func internalConstructor()
    {
        objectIndex = glh_atomic_add_uint64(&GObject.objectIndexCount, 1);
        
        self.OnConstruct();
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
