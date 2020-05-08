//
//  Rect.swift
//  
//
//  Created by Alex Griffin on 14/1/20.
//

public struct Size
{
    public let Width: Float;
    public let Height: Float;
    
    public init(_ width: Float, _ height: Float)
    {
        Width = width;
        Height = height;
    }
}

public struct Quad
{
    public let TL: Vec2;
    public let TR: Vec2;
    public let BL: Vec2;
    public let BR: Vec2;
    
    public init(tl: Vec2, tr: Vec2, bl: Vec2, br: Vec2)
    {
        self.TL = tl;
        self.TR = tr;
        self.BL = bl;
        self.BR = br;
    }
    
    public init(_ rect: Rect)
    {
        self.TL = rect.Position;
        self.TR = Vec2(rect.x + rect.width, rect.y);
        self.BL = Vec2(rect.x, rect.y + rect.height);
        self.BR = Vec2(rect.x + rect.width, rect.y + rect.height);
    }
}

public struct Rect
{
    public let Position: Vec2; //Top Left
    public let Size: Size; //Bottom Right
    
    @inline (__always) public var x: Float { get { return Position.x; } }
    @inline (__always) public var y: Float { get { return Position.y; } }
    @inline (__always) public var width: Float { get { return Size.Width; } }
    @inline (__always) public var height: Float { get { return Size.Height; } }
    
    public init (_ position: Vec2, _ size: Size)
    {
        Position = position;
        Size = size;
    }
}

