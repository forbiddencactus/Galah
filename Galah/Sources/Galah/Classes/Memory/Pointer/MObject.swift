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


open class MObject
{
    public func OnConstruct() {}
    
    // Construct an instance of the specified MObject.
    public static func Construct<T>() -> T? where T: MObject
    {
        return MObject.Construct(type: T.self) as? T;
    }
    
    // Construct into the specified pointer.
    @discardableResult
    public static func Construct<T>(_ ptr: Ptr<T>) -> T? where T: MObject
    {
        return unsafeBitCast(MObject.Construct(type: T.self, ptr: ptr.GetVoidPtr()), to: T.self);
    }
    
    public static func Construct(type: MObject.Type) -> MObject?
    {
        let constr: MObject;

        do
        {
            constr = try unsafeBitCast(buildClass(type: type), to: MObject.self);
            
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
    public static func Construct(type: MObject.Type, ptr: Ptr<VoidPtr>) -> MObject?
    {
        let constr: MObject;
        do
        {
            constr = try unsafeBitCast(galah_placementNew(type: type, ptr: ptr), to: MObject.self);
            
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
    
    private func internalConstructor()
    {
        self.OnConstruct();
    }
}
