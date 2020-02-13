//
//  Texture.swift
//  
//
//  Created by Alex Griffin on 14/1/20.
//


public class Texture
{
    public let PointerToTexture: UnsafeMutableRawPointer; //A pointer to the texture in native renderer memory.
    public let PixelFormat: Int; //The equivalent int value for the render API's native pixel format enumeration. 
    public let Size: Size<Int>; //The size of this texture, in width and height.
    
    public init(_ pointerToTexture: UnsafeMutableRawPointer,_ size: Size<Int>,_ pixelFormat: Int)
    {
        PointerToTexture = pointerToTexture;
        PixelFormat = pixelFormat;
        Size = size;
    }
}
