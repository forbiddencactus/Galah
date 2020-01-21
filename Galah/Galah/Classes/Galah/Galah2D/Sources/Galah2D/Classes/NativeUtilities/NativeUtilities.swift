//
//  File.swift
//  
//
//  Created by Alex Griffin on 14/1/20.
//


public func GetPointerFromObject(_ object: AnyObject) -> UnsafeMutableRawPointer
{
    return UnsafeMutableRawPointer(Unmanaged.passRetained(object).toOpaque());
}
