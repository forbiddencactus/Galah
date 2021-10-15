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

open class GObject
{
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
            constr.internallyConstructed = true;
            
            // run our fake init
            constr.internalConstructor();
            
            retainObject(constr);
                    
            return constr;
        }
        catch
        {
            return nil;
        }
    }
    
    @discardableResult
    internal static func Construct(type: GObject.Type, ptr: Ptr<VoidPtr>) -> GObject?
    {
        let constr: GObject;
        do
        {
            constr = try galah_placementNew(type: type, ptr: ptr) as! GObject;
            constr.internallyConstructed = true;
            //try constr.init();
        }
        catch
        {
            return nil;
        }
        
        retainObject(constr);
        
        //constr.internalConstruct();
        
        return constr;
    }
        
    // Call this to indicate to the object to no longer update its position with the object table.
    internal func HasBeenCopied()
    {
        objectIndex = GIndex();
    }
    
    // Call this after the object copy, on the object's copy, so that the object table is updated.
    internal func IsCopied()
    {
        GObjectTable.sharedInstance.UpdateObject(index: objectIndex, reference: self);
    }
    
    private var objectIndex: GIndex = GIndex();
    private var willDestroy: Bool = false;
    private var internallyConstructed: Bool = false;
    
    // BIG NOTE: Unfortunately I couldn't (yet) figure out a way to run init() using our custom allocation stuff.
    private init() throws
    {
        if(internallyConstructed != true)
        {
            // GObjects are manually managed by the engine. You can't construct them yourself!
            throw GObjectError.NotProperlyConstructed;
        }
    }
    
    private func internalConstructor()
    {
        objectIndex = GObjectTable.sharedInstance.GetNewGIndex();
        GObjectTable.sharedInstance.UpdateObject(index: objectIndex, reference: self);
        
        self.OnConstruct();
    }
    
    deinit
    {
        GObjectTable.sharedInstance.RemoveObject(objectIndex);
    }
}

public enum GObjectError: Error
{
    // GObjects are manually managed by the engine. You can't construct them yourself!
    case NotProperlyConstructed;
    case AllocError;
}
