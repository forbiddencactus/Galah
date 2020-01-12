//
//  RenderTarget.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

public class RenderTarget
{
    public var TargetPointer: UnsafeMutableRawPointer;
    
    init(targetPointer: UnsafeMutableRawPointer)
    {
        TargetPointer = targetPointer;
    }
}
