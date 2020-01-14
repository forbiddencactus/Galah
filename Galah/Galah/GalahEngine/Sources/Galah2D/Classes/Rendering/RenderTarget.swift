//
//  RenderTarget.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

public class RenderTarget
{
    public var TargetPointer: UnsafeMutableRawPointer;
    
    public init(_ targetPointer: UnsafeMutableRawPointer)
    {
        TargetPointer = targetPointer;
    }
}
