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
// Placement new allocators and other things for manual memory management.

/*
 Special thanks to these websites for helping me comprehend Swift's runtime:
 https://kateinoigakukun.hatenablog.com/entry/2019/03/22/184356
 https://belkadan.com/blog/2020/08/Swift-Runtime-Heap-Objects/
 https://cdmana.com/2021/02/20210214042606386H.html
 https://github.com/wickwirew/Runtime
 */
// Cheers to Wes Wickwire for their awesome work opening up the Swift runtime! Functional swift here we come!

import GalahNative.SwiftRuntime;

internal func galah_placementNew<T>(_ ptr: Ptr<T>) throws -> T where T: AnyObject
{
    return try galah_placementNew(type: T.self, ptr: ptr.GetVoidPtr()) as! T;
}

internal func galah_placementNew(type: Any.Type, ptr: Ptr<VoidPtr>) throws -> AnyObject
{
    var md = ClassMetadata(type: type.self);
    let info = md.toTypeInfo();
    let metadata = unsafeBitCast(type.self, to: UnsafeRawPointer.self);

    // Not sure we need this alignment stuff for now...
    // let alignmentMask = Int32(md.pointer.pointee.instanceAlignmentMask)

    let value: UnsafeMutableRawPointer = ptr.raw!;

    value.storeBytes(of: metadata, as: UnsafeRawPointer.self);
    try setProperties(typeInfo: info, pointer: UnsafeMutableRawPointer(mutating: value));
    
    // Increment the strong retain by one because we want to manually manage this object.
    value.assumingMemoryBound(to: ClassHeader.self).pointee.strongRetainCounts += 1;

    return unsafeBitCast(value, to: AnyObject.self);
}

public func galah_runDestructor(obj: AnyObject)
{
    let md = ClassMetadata(type: GObject.self);

    let rawObjectRef = unsafeBitCast(obj, to: UnsafeMutableRawPointer.self);
    
    let testRef = rawObjectRef;
    let meta = testRef.load(as: UnsafePointer<ClassTypeDescriptor>.self);

    // https://github.com/apple/swift/blob/main/docs/ABI/TypeMetadata.rst#common-metadata-layout
    let destroyPtr = UnsafeRawPointer(meta) - ( MemoryLayout<Int>.size  * 2);
    
    
    glh_runSwiftDestructor(unsafeBitCast(md.destructor, to: UnsafeMutablePointer<UnsafeMutableRawPointer?>?.self), rawObjectRef);
}
