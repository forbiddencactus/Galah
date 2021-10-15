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
// An unsafe C style pointer, with all the overloads and other good things.

import GalahNative.Memory;

public typealias VoidPtr = Int;

// The difference between this and the swift stuff is that the swift stuff uses the size of a ref for any ref type, we use the actual size on the heap.
public struct Ptr<T>
{
    @usableFromInline
    internal let size: GMemSize;
    
    @usableFromInline
    internal var ptr: GPtr = GPtr(); //GPtr is basically our void*.
    
    @inlinable
    @inline(__always)
    public var gptr: GPtr { get { return ptr; } };
    
    @inlinable
    @inline(__always)
    public var raw: UnsafeMutableRawPointer? { get { return ptr.ptr; } };
    
    
    public static func Null() -> Ptr<T>
    {
        return Ptr<T>();
    }
    
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
    
    public func RunFunc<R>(_ body: (T) throws -> R) rethrows -> R
    {
        let tmp = unsafeBitCast(ptr.ptr, to: T.self);
        return try body(tmp);
    }
    
    public mutating func IsNull() -> Bool
    {
        if (ptr_getnull(&ptr))
        {
            return true;
        }
        
        return false;
    }
    
    public init()
    {
        size = SizeOf(T.self);
        ptr_setnull(&ptr);
    }
    
    public init(_ rawPointer: UnsafeMutableRawPointer)
    {
        size = ExtentsOf(T.self);
        ptr.ptr = rawPointer;
    }
    
    public init(_ gPointer: GPtr)
    {
        size = ExtentsOf(T.self);
        ptr = gPointer;
    }
    
    public init(_ pointer: Ptr<T>)
    {
        size = pointer.size;
        ptr = pointer.ptr;
    }
    
    public init (_ pointer: Ptr<VoidPtr>)
    {
        size = ExtentsOf(T.self);
        ptr = pointer.ptr;
    }
    
    // Usage: Ptr(obj), naturally no guarantee is made to the pointee's lifespan.
    // Creates a pointer from a pointer or reference. ptr* ptr = 
    public init(_ object: inout T)
    {
        size = ExtentsOf(T.self);
        ptr_set(&ptr, &object);
    }
    
    public init(_ anyObj: inout Any)
    {
        size = ExtentsOf(T.self);
        ptr_set(&ptr, &anyObj);
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
    public mutating func Set(ptr: inout Ptr<Any>, size: GMemSize)
    {
        ptr_assign(&self.ptr, &ptr.ptr.ptr, size);
    }
    
    // Returns a new pointer that points to this pointer.
    @inlinable
    @inline(__always)
    public func GetPointerToThis() -> Ptr<VoidPtr>
    {
        return Ptr<VoidPtr>(ptr_get_ptr_to_ptr(self.ptr));
    }
    
    // Returns a void pointer from this pointer.
    @inlinable
    @inline(__always)
    public func GetVoidPtr() -> Ptr<VoidPtr>
    {
        return Ptr<VoidPtr>(ptr);
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
