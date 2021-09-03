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
// Pointer utilities.

import GalahNative.Memory;

public struct GetSize<T>
{
    public static func SizeOf() -> MemSize
    {
        let kind = Kind(type: T.self);
        switch kind
        {
            case .struct:
                do
                {
                    return try typeInfo(of: T.self).size;
                }
                catch
                {
                    return 0;
                }
            
            case .class:
                let md = ClassMetadata(type: T.self);
                return Int(md.pointer.pointee.instanceSize)
            
            default:
                return 0;
        }
    }
}

// Gets the size on the heap of a ref or value.
public func SizeOf(_ value: inout Any) -> MemSize
{
    if (value is AnyClass)
    {
        let md = ClassMetadata(type: type(of: value));
        return Int(md.pointer.pointee.instanceSize)
    }
    else
    {
        return MemoryLayout.stride(ofValue: value);
    }
}

@_silgen_name("swift_class_getInstanceExtents") func swift_class_getInstanceExtents(theClass: AnyClass) -> (negative: UInt, positive: UInt)


// Gets the pointer to an object without retaining it.
public func GetPointerFromObject(_ object: AnyObject) -> UnsafeMutableRawPointer
{
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(object).toOpaque());
}

// Gets the pointer to an object whilst retaining it.
public func GetRetainedPointerFromObject(_ object: AnyObject) -> UnsafeMutableRawPointer
{
    return UnsafeMutableRawPointer(Unmanaged.passRetained(object).toOpaque());
}

// Gets an unretained ref to a pointer.
public func GetRefFromPointer(_ pointer: UnsafeMutableRawPointer) -> AnyObject?
{
    let ptr = Unmanaged<AnyObject>.fromOpaque(pointer);
    return ptr.takeUnretainedValue();
}

// Gets an unretained ref to a pointer of type T.
public func GetRefFromPointer<T>(_ pointer: UnsafeMutableRawPointer) ->T?
{
    let ptr = GetRefFromPointer(pointer);
    
    if(ptr is T)
    {
        return ptr as! T?
    }
    else
    {
        return nil;
    }
}

// Releases a pointer
public func ReleasePointer(_ pointer: UnsafeMutableRawPointer)
{
    Unmanaged<AnyObject>.fromOpaque(pointer).release();
}
