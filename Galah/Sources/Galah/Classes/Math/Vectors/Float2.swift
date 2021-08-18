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
//  Created by Alex Griffin on 29/12/19.
//

import GalahNative.Maths

public struct Float2
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
        vec = NativeFloat2(x: vec.x * vector.x, y: vec.y * vector.y);
    }
}
