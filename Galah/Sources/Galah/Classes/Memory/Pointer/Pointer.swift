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

// An unsafe C style pointer, with all the overloads and other good things.
struct Ptr<T>
{
    private let size: MemSize;
    private var ptr: GPtr = GPtr(); //GPtr is basically our void*.
    
    @inlinable
    @inline(__always)
    public var raw: GPtr { get { return ptr; } };
    
    // Allocates a pointer of size of the pointer element * count.
    public static func Allocate(_ count: GUInt) -> Ptr<T>
    {
        var retPtr = Ptr();
        retPtr.ptr.ptr = glh_malloc(retPtr.size * Int(count));
        return retPtr;
    }
    
    // Allocates a pointer of size of the pointer's element. 
    public static func Allocate() -> Ptr<T>
    {
        var retPtr = Ptr();
        retPtr.ptr.ptr = glh_malloc(retPtr.size);
        return retPtr;
    }
    
    public static func Free(_ ptr: Ptr<T>)
    {
        glh_free(ptr.ptr.ptr);
    }
    
    public init()
    {
        ptr_setnull(&ptr);
    }
    
    public init(_ rawPointer: UnsafeMutableRawPointer)
    {
        size = GetSize<T>.SizeOf();
        ptr.ptr = rawPointer;
    }
    
    public init(_ gPointer: GPtr)
    {
        size = GetSize<T>.SizeOf();
        ptr = gPointer;
    }
    
    public init(_ pointer: Ptr<T>)
    {
        size = pointer.size;
        ptr = pointer.ptr;
    }
    
    // Usage: Ptr(obj), naturally no guarantee is made to the pointee's lifespan.
    // Creates a pointer from a pointer or reference. ptr* ptr = 
    public init(_ object: inout T)
    {
        size = GetSize<T>.SizeOf();
        ptr_set(&ptr, &object);
    }
    
    // Copies the value of value into the location pointed to by lhs.
    @inlinable
    @inline(__always)
    public mutating func Set(_ value: inout T)
    {
        self *= value;
    }
    
    // Like above. Watch out for overflows!
    @inlinable
    @inline(__always)
    public mutating func Set(_ value: inout Any)
    {
        self *= value;
    }
    
    // Set the data pointed by ptr with the specified size.
    @inlinable
    @inline(__always)
    public mutating func Set(ptr: inout Ptr<Any>, size: MemSize)
    {
        ptr_assign(&self.ptr, &ptr.ptr.ptr, size);
    }
    
    //############
    //OPERATORS
    //############
    
    // Assignment & set: sorry about the syntax, Swift doesn't like overriding = :(

    // Assignment: Coming soon. Just construct a new one? :P
    
    // Set:
    
    // Copies the value of rhs into the location pointed to by lhs.
    @inlinable
    @inline(__always)
    public static func *=(lhs: inout Ptr<T>, rhs: inout T)
    {
        ptr_assign(&lhs.ptr, &rhs, lhs.size);
    }
    
    // Like above. Watch out for overflows!
    @inlinable
    @inline(__always)
    public static func *=(lhs: inout Ptr<T>, rhs: inout Any)
    {
        ptr_assign(&lhs.ptr, &rhs, SizeOf(&rhs));
    }
    
    // Maths stuff.
    
    @inlinable
    @inline(__always)
    public static func +(lhs: Ptr<T>, rhs: GUInt) -> Ptr<T>
    {
        return Ptr<T>.init(ptr_add(lhs.ptr, lhs.size, rhs));
    }
    
    @inlinable
    @inline(__always)
    public static func +=( lhs: inout Ptr<T>, rhs: GUInt)
    {
        lhs.ptr = ptr_add(lhs.ptr, lhs.size, rhs);
    }
    
    @inlinable
    @inline(__always)
    public static func -(lhs: Ptr<T>, rhs: GUInt) -> Ptr<T>
    {
        return Ptr<T>.init(ptr_sub(lhs.ptr, lhs.size, rhs));
    }
    
    @inlinable
    @inline(__always)
    public static func -=( lhs: inout Ptr<T>, rhs: GUInt)
    {
        lhs.ptr = ptr_sub(lhs.ptr, lhs.size, rhs);
    }
}
