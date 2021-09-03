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
// An object which is manually managed by the Galah engine. Base object for most Galah things.

open class GObject
{
    // Called whenever Galah constructs the instance.
    public func OnConstruct() {}
    
    // Called whenever Galah destroys the instance.
    public func OnDestroy() {}
        
    // Construct an instance of the specified GObject.
    public static func Construct<T>() -> T? where T: GObject
    {
        internallyConstructed = true;
        let constr: T;
        do
        {
            constr = try T();
        }
        catch
        {
            return nil;
        }
        
        retainObject(constr);
        
        constr.OnConstruct();
        
        return constr;
    }
    
    // Construct into the specified pointer.
    public static func Construct<T>(_ ptr: Ptr<T>) -> T? where T: GObject
    {
        internallyConstructed = true;
        let constr: T;
        do
        {
            constr = try galah_placementNew(ptr);
        }
        catch
        {
            return nil;
        }
                
        constr.OnConstruct();
        
        return constr;
    }
    
    private static var internallyConstructed: Bool = false;

    // TODO: Investigate replacing OnConstruct with just the required init?
    public required init() throws
    {
        if(GObject.internallyConstructed != true)
        {
            throw GObjectError.NotProperlyConstructed;
            return;
        }
        GObject.internallyConstructed = false;
    };
}

public enum GObjectError: Error
{
    // GObjects are manually managed by the engine. Don't use init!
    case NotProperlyConstructed;
    case AllocError;
}
