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
// Pointer utilities.

// Some useful links RE how Swift allocates memory:
// https://github.com/apple/swift/blob/main/stdlib/public/runtime/HeapObject.cpp
// https://github.com/apple/swift/blob/main/stdlib/public/runtime/Heap.cpp
// https://github.com/apple/swift/blob/main/include/swift/Basic/Malloc.h
// https://belkadan.com/blog/2020/08/Swift-Runtime-Heap-Objects/
// https://swiftunboxed.com/internals/size-stride-alignment/
// https://github.com/apple/swift/blob/main/docs/ABI/TypeLayout.rst

import GalahNative.Memory;

// Gets the size of a struct or class. Will return 8 bytes for other reference types, or 0 if it fails.
public func SizeOf(_ type: Any.Type) -> GMemSize
{
    let kind = Kind(type: type.self);
    switch kind
    {
        case .class:
            let md = ClassMetadata(type: type);
            return SizeOf(md);
        
        default:
            do
            {
                return try typeInfo(of: type.self).size;
            }
            catch
            {
                return 0;
            }
    }
}

// Gets the size of a class.
public func SizeOf(_ type: AnyClass) -> GMemSize
{
    let md = ClassMetadata(type: type.self);
    return SizeOf(md);
}

// Gets the size of a ref type or value.
public func SizeOf(_ value: inout Any) -> GMemSize
{
    if (value is AnyClass)
    {
        let md = ClassMetadata(pointer: Cast(&value));
        return SizeOf(md);
    }
    else
    {
        return MemoryLayout.size(ofValue: value);
    }
}

// Gets the size on the heap of a struct or class. Will return 8 bytes for other reference types, or 0 if it fails.
public func ExtentsOf(_ type: Any.Type) -> GMemSize
{
    let kind = Kind(type: type.self);
    switch kind
    {
        case .class:
            let md = ClassMetadata(type: type);
            return ExtentsOf(md);
        
        default:
            do
            {
                return try typeInfo(of: type.self).stride;
            }
            catch
            {
                return 0;
            }
    }
}

// Gets the size on the heap of a ref or value.
public func ExtentsOf(_ value: inout Any) -> GMemSize
{
    if (value is AnyClass)
    {
        let md = ClassMetadata(pointer: Cast(&value));
        return ExtentsOf(md);
    }
    else
    {
        return MemoryLayout.stride(ofValue: value);
    }
}

// Gets the size on the heap of a class type.
public func ExtentsOf(_ type: AnyClass) -> GMemSize
{
    let md = ClassMetadata(type: type.self);
    return ExtentsOf(md);
}

// Gets the size on the heap of an object ref.
public func ExtentsOf(_ obj: AnyObject) -> GMemSize
{
    let md = ClassMetadata(type: type(of: obj));
    return ExtentsOf(md);
}

public func GetPointer<T>(_ value: inout T) -> UnsafeMutableRawPointer
{
    return Cast(&value);
}

// Gets the pointer to an object without retaining it.
public func GetPointerFromObject(_ object: AnyObject) -> UnsafeMutableRawPointer
{
    return Cast(object);
}

// Gets an unretained ref to a pointer.
public func GetRefFromPointer(_ pointer: UnsafeMutableRawPointer?) -> AnyObject?
{
    return Cast(pointer);
}

// Gets an unretained ref to a pointer of type T.
public func GetRefFromPointer<T>(_ pointer: UnsafeMutableRawPointer) ->T?
{
    return Cast(pointer);
}

// Casts the object into T
public func Cast<T>(_ input: inout Any?) -> T
{
    return unsafeBitCast(input, to: T.self);
}

public func Cast<T>(_ input: UnsafeMutableRawPointer?) -> T
{
    return unsafeBitCast(input, to: T.self);
}

public func Cast<T>(_ input: AnyObject?) -> T
{
    return unsafeBitCast(input, to: T.self);
}

internal func SizeOf(_ classMeta: ClassMetadata) -> GMemSize
{
    return Int(classMeta.pointer.pointee.instanceSize);
}

internal func ExtentsOf(_ classMeta: ClassMetadata) -> GMemSize
{
    let size = Float(classMeta.pointer.pointee.instanceSize);
    let alignment = Float(classMeta.pointer.pointee.instanceAlignmentMask + 1);
    return Int(alignment * (size / alignment).rounded(FloatingPointRoundingRule.up));
}
