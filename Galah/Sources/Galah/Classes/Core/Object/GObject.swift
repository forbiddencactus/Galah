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
    internal static func Construct<T>() -> T? where T: GObject
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
        
        constr.internalConstruct();
        
        return constr;
    }
    
    // Construct into the specified pointer.
    @discardableResult
    internal static func Construct<T>(_ ptr: Ptr<T>) -> T? where T: GObject
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
                
        constr.internalConstruct();
        
        return constr;
    }
        
    // Call this to indicate to the object to no longer update its position with the object table.
    internal func WillCopy()
    {
        shouldUpdateTable = false;
    }
    
    // Call this after the object copy, on the object's copy, so that the object table is updated.
    internal func IsCopied()
    {
        GObjectTable.sharedInstance.UpdateObject(index: objectIndex, reference: self);
    }
    
    private var objectIndex: GIndex = 0;
    private var willDestroy: Bool = false;
    private var shouldUpdateTable: Bool = true;
    
    private func internalConstruct()
    {
        objectIndex = GObjectTable.sharedInstance.GetNewGIndex();
        GObjectTable.sharedInstance.UpdateObject(index: objectIndex, reference: self);
        
        self.OnConstruct();
    }
    
    private func internalDestruct()
    {
        if(shouldUpdateTable)
        {
            GObjectTable.sharedInstance.RemoveObject(objectIndex);
        }
        
        self.OnDestroy();
    }

    private static var internallyConstructed: Bool = false;
    // TODO: Investigate replacing OnConstruct with just the required init?
    public required init() throws
    {
        if(GObject.internallyConstructed != true)
        {
            // GObjects are manually managed by the engine. You can't construct them yourself!
            throw GObjectError.NotProperlyConstructed;
            return;
        }
        GObject.internallyConstructed = false;
    };
}

public enum GObjectError: Error
{
    // GObjects are manually managed by the engine. You can't construct them yourself!
    case NotProperlyConstructed;
    case AllocError;
}
