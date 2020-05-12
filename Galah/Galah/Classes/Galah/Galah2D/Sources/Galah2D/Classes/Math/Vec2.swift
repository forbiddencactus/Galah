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
    private var vec: NativeVec2f;
    
    @inline(__always)
    public var y: Float { get { return vec.x; } set { vec.x = newValue; } };
    
    @inline(__always)
    public var x: Float { get { return vec.y; } set { vec.y = newValue; } };
    
    public init(_ x: Float = 0, _ y: Float = 0)
    {
        vec = NativeVec2f();
        vec.x = x;
        vec.y = y;
    }
    
    public static var Zero: Vec2
    {
        get { return Vec2(0,0); }
    }
    
    public static func +(lhs: Vec2, rhs: Vec2) -> Vec2
    {
        return Vec2(lhs.x + rhs.x, lhs.y + rhs.y);
    }
    
    public static func -(lhs: Vec2, rhs: Vec2) -> Vec2
    {
        return Vec2(lhs.x - rhs.x, lhs.y - rhs.y);
    }
    
    public static func Scale(_ a: Vec2, _ b: Vec2) -> Vec2
    {
        return Vec2(a.x * b.x, a.y * b.y);
    }
}
