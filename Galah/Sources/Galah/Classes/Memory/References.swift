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
// A wrapper for a Swift ref, to avoid retain perf hits, and other utilities. 

import GalahNative.SwiftRuntime;

public struct Ref<T> where T: GObject
{
    @usableFromInline
    internal unowned(unsafe) var _ref: T?

    @usableFromInline @_transparent
    internal init(ref: T) { _ref = ref; }
    
    @usableFromInline @_transparent
    internal init(_ ptr: UnsafeMutableRawPointer) { _ref = Cast(ptr); }
    
    @usableFromInline @_transparent
    internal init(_ ptr: Ptr<VoidPtr>) { _ref = Cast(ptr.raw); }
    
    @usableFromInline @_transparent
    internal init(_ ptr: Ptr<T>) { _ref = Cast(ptr.raw); }
    
    @inlinable @inline(__always)
    internal unowned(unsafe) var ref: T?
    {
        get
        {
            return _ref;
        }
    }

    @inlinable
    @_transparent
    public func FastFunc<R>(_ body: (T) throws -> R) rethrows -> R
    {
        let tmp = self;
        return try body(tmp._ref!);
    }
}

internal func retainObject(_ object: AnyObject)
{
    let ptr = GetPointerFromObject(object);
    ptr.assumingMemoryBound(to: ClassHeader.self).pointee.strongRetainCounts += 1;
}

public func setObjectRetain(_ object: AnyObject, _ newRetain: Int32)
{
    let ptr = GetPointerFromObject(object);
    //ptr.assumingMemoryBound(to: ClassHeader.self).pointee.strongRetainCounts = newRetain;
    var mutate = object;
    
    //(ptr + 8).assumingMemoryBound(to: Int64.self).pointee = Int64(newRetain);
    
    return try! withValuePointer(of: &mutate) { pointer in
        pointer.assumingMemoryBound(to: ClassHeader.self).pointee.strongRetainCounts = newRetain;
    }
    //galah_set_refcount(&mutate, 1);
}

// Note that this won't, as of yet, dealloc the object if you decrease the refcount.
internal func releaseObject(_ object: AnyObject)
{
    let ptr = GetPointerFromObject(object);
    ptr.assumingMemoryBound(to: ClassHeader.self).pointee.strongRetainCounts -= 1;
}
