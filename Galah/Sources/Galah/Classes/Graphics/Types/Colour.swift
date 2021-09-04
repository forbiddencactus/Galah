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

import GalahNative.Maths;

public struct Colour
{
    private var col: GFloat4;
    
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
        col = GFloat4(x: red, y: green, z: blue, w: alpha);
    }
}

typealias Col = Colour;
