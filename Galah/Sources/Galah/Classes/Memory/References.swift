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

internal struct Ref<T> where T: GObject
{
    @usableFromInline
    internal unowned(unsafe) var _ref: T?

    @usableFromInline @_transparent
    internal init(ref: T) { _ref = ref; }
    
    @usableFromInline @_transparent
    internal init(_ ptr: UnsafeMutableRawPointer) { _ref = Cast(ptr); }
    
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
    _ = Unmanaged.passRetained(object);
}

internal func releaseObject(_ object: AnyObject)
{
    let release = Unmanaged.passUnretained(object);
    release.release();
}
