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
// Float2 vector type.

import GalahNative.Maths

public struct Float2
{
    @usableFromInline
    internal var vec: GFloat2;
    
    @inlinable
    @inline(__always)
    public var y: Float { get { return vec.x; } set { vec.x = newValue; } };
    
    @inlinable
    @inline(__always)
    public var x: Float { get { return vec.y; } set { vec.y = newValue; } };
    
    @inlinable
    @inline(__always)
    public init(_ x: Float = 0, _ y: Float = 0)
    {
        vec = GFloat2(x: x, y: y);
    }
    
    //Constructs a zero vector.
    @inlinable
    @inline(__always)
    public static var Zero: Float2
    {
        get { return Float2(0,0); }
    }
    
    //############
    //OPERATORS
    //############
    
    @inlinable
    @inline(__always)
    public static func +(lhs: Float2, rhs: Float2) -> Float2
    {
        return Float2(lhs.x + rhs.x, lhs.y + rhs.y);
    }
    
    @inlinable
    @inline(__always)
    public static func +=( lhs: inout Float2, rhs: Float2)
    {
        lhs = lhs - rhs;
    }
    
    @inlinable
    @inline(__always)
    public static func -(lhs: Float2, rhs: Float2) -> Float2
    {
        return Float2(lhs.x - rhs.x, lhs.y - rhs.y);
    }
    
    @inlinable
    @inline(__always)
    public static func -=( lhs: inout Float2, rhs: Float2)
    {
        lhs = lhs - rhs;
    }
    
    @inlinable
    @inline(__always)
    public static func *(lhs: Float2, rhs: Float) -> Float2
    {
        return Float2(lhs.x * rhs, lhs.y * rhs);
    }
    
    @inlinable
    @inline(__always)
    public static func *=(lhs: inout Float2, rhs: Float)
    {
        lhs = lhs * rhs;
    }
    
    @inlinable
    @inline (__always)
    public static func /(lhs: Float2, rhs: Float) -> Float2
    {
        return Float2( lhs.x / rhs, lhs.y / rhs );
    }
    
    @inlinable
    @inline(__always)
    public static func /=(lhs: inout Float2, rhs: Float)
    {
        lhs = lhs / rhs;
    }
    
    @inlinable
    @inline(__always)
    public static func Scale(_ a: Float2, _ b: Float2) -> Float2
    {
        return Float2(a.x * b.x, a.y * b.y);
    }
    
    @inlinable
    @inline(__always)
    public mutating func Scale(_ vector: Float2)
    {
        vec = GFloat2(x: vec.x * vector.x, y: vec.y * vector.y);
    }
}
