//
//  Vec2.swift
//  Galah
//
//  Created by Alex Griffin on 29/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

public struct Vec2
{
    var x: Float = 0;
    var y: Float = 0;
    
    init(x: Float = 0, y: Float = 0)
    {
        self.x = x;
        self.y = y;
    }
    
    init(_ x: Float = 0, _ y: Float = 0)
    {
        self.init(x: x, y: y);
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
