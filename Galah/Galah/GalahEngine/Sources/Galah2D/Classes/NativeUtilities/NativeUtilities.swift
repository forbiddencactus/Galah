//
//  File.swift
//  
//
//  Created by Alex Griffin on 14/1/20.
//


public func GetPointerFromObject<T: AnyObject>(_ object: T) -> UnsafeMutableRawPointer
{
    return UnsafeMutableRawPointer(Unmanaged.passRetained(object).toOpaque());
}
