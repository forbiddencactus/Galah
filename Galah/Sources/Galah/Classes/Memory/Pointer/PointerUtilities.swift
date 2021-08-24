/*
MIT License

Copyright © 2020, 2021 Alexis Griffin.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import GalahNative.Memory;
import SwiftShims;

public struct GetSize<T>
{
    public static func SizeOf() -> MemSize
    {
        let theClass: T.Type = T.self;

        if (theClass is AnyClass)
        {
            let ret = swift_class_getInstanceExtents(theClass: theClass as! AnyClass);
            return MemSize(ret.positive);
        }
        else
        {
            return MemoryLayout<T>.stride;
        }
    }
}

// Gets the size on the heap of a ref or value.
public func SizeOf(_ value: inout Any) -> MemSize
{
    if (value is AnyClass)
    {
        return _swift_stdlib_malloc_size(&value);
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
