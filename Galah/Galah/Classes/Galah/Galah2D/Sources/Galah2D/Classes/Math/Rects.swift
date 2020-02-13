//
//  Rect.swift
//  
//
//  Created by Alex Griffin on 14/1/20.
//

public struct Size<T: Numeric>
{
    public let Width: T;
    public let Height: T;
    
    public init(_ width: T, _ height: T)
    {
        Width = width;
        Height = height;
    }
}

public struct Quad<T: Numeric>
{
    public let TL: Vec2<T>;
    public let TR: Vec2<T>;
    public let BL: Vec2<T>;
    public let BR: Vec2<T>;
    
    public init(tl: Vec2<T>, tr: Vec2<T>, bl: Vec2<T>, br: Vec2<T>)
    {
        self.TL = tl;
        self.TR = tr;
        self.BL = bl;
        self.BR = br;
    }
    
    public init(_ rect: Rect<T>)
    {
        self.TL = rect.Position;
        self.TR = Vec2(rect.x + rect.width, rect.y);
        self.BL = Vec2(rect.x, rect.y + rect.height);
        self.BR = Vec2(rect.x + rect.width, rect.y + rect.height);
    }
}

public struct Rect<T: Numeric>
{
    public let Position: Vec2<T>; //Top Left
    public let Size: Size<T>; //Bottom Right
    
    public var x { get { return Position.x; } }
    public var y { get { return Position.y; } }
    public var width { get { return Size.Width; } }
    public var height { get { return Size.Height; } }
    
    public init (_ position: Vec2<T>, _ size: Size<T>)
    {
        Position = position;
        Size = size;
    }
}

