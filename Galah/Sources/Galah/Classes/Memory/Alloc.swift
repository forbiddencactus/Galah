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

internal func galah_placementNew<T>(_ ptrToPlace: Ptr<T>) throws -> T where T: AnyObject
{
    var md = ClassMetadata(type: T.Type.self);
    let info = md.toTypeInfo();
    let metadata = unsafeBitCast(T.self, to: UnsafeRawPointer.self);

    // Not sure we need this alignment stuff for now...
    // let alignmentMask = Int32(md.pointer.pointee.instanceAlignmentMask)

    let value: UnsafeMutableRawPointer = ptrToPlace.raw.ptr!;

    value.storeBytes(of: metadata, as: UnsafeRawPointer.self);
    try setProperties(typeInfo: info, pointer: UnsafeMutableRawPointer(mutating: value));
    
    // Increment the strong retain by one because we want to manually manage this object.
    value.assumingMemoryBound(to: ClassHeader.self).pointee.strongRetainCounts += 1;

    return unsafeBitCast(value, to: AnyObject.self) as! T;
}
