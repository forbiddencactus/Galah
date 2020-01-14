//
//  Rect.swift
//  
//
//  Created by Alex Griffin on 14/1/20.
//

public struct Rect<T: Numeric>
{
    public let Width: T;
    public let Height: T;
    
    public init(_ width: T, _ height: T)
    {
        Width = width;
        Height = height;
    }
}
