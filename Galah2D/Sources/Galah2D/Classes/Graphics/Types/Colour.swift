//
//  File.swift
//  
//
//  Created by Alex Griffin on 14/1/20.
//

import GalahNativeTypes.Maths.Vector;

public struct Colour
{
    private var col: NativeFloat4;
    
    @inline(__always)
    public var r: Float { get { return col.x; } set { col.x = newValue; } };
    @inline(__always)
    public var g: Float { get { return col.y; } set { col.x = newValue; } };
    @inline(__always)
    public var b: Float { get { return col.z; } set { col.x = newValue; } };
    @inline(__always)
    public var a: Float { get { return col.w; } set { col.x = newValue; } };
    
    public init(_ red: Float,_ green: Float,_ blue: Float,_ alpha: Float)
    {
        col = NativeFloat4(x: red, y: green, z: blue, w: alpha);
    }
}
