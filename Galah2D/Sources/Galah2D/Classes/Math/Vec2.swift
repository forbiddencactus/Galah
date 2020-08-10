//
//  Vec2.swift
//  Galah
//
//  Created by Alex Griffin on 29/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

import GalahNativeTypes.Maths.Vector

public struct Vec2
{
    @usableFromInline
    internal var vec: NativeFloat2;
    
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
        vec = NativeFloat2(x: x, y: y);
    }
    
    //Constructs a zero vector.
    @inlinable
    @inline(__always)
    public static var Zero: Vec2
    {
        get { return Vec2(0,0); }
    }
    
    //############
    //OPERATORS
    //############
    
    @inlinable
    @inline(__always)
    public static func +(lhs: Vec2, rhs: Vec2) -> Vec2
    {
        return Vec2(lhs.x + rhs.x, lhs.y + rhs.y);
    }
    
    @inlinable
    @inline(__always)
    public static func +=( lhs: inout Vec2, rhs: Vec2)
    {
        lhs = lhs - rhs;
    }
    
    @inlinable
    @inline(__always)
    public static func -(lhs: Vec2, rhs: Vec2) -> Vec2
    {
        return Vec2(lhs.x - rhs.x, lhs.y - rhs.y);
    }
    
    @inlinable
    @inline(__always)
    public static func -=( lhs: inout Vec2, rhs: Vec2)
    {
        lhs = lhs - rhs;
    }
    
    @inlinable
    @inline(__always)
    public static func *(lhs: Vec2, rhs: Float) -> Vec2
    {
        return Vec2(lhs.x * rhs, lhs.y * rhs);
    }
    
    @inlinable
    @inline(__always)
    public static func *=(lhs: inout Vec2, rhs: Float)
    {
        lhs = lhs * rhs;
    }
    
    @inlinable
    @inline (__always)
    public static func /(lhs: Vec2, rhs: Float) -> Vec2
    {
        return Vec2( lhs.x / rhs, lhs.y / rhs );
    }
    
    @inlinable
    @inline(__always)
    public static func /=(lhs: inout Vec2, rhs: Float)
    {
        lhs = lhs / rhs;
    }
    
    @inlinable
    @inline(__always)
    public static func Scale(_ a: Vec2, _ b: Vec2) -> Vec2
    {
        return Vec2(a.x * b.x, a.y * b.y);
    }
    
    @inlinable
    @inline(__always)
    public mutating func Scale(_ vector: Vec2)
    {
        vec = NativeFloat2(x: vec.x * vector.x, y: vec.y * vector.y);
    }
}
