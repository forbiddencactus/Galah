//
//  NativeUtilities.swift
//  
//
//  Created by Alex Griffin on 14/1/20.
//



//Gets the pointer to an object an retains it.
public func GetPointerFromObject(_ object: AnyObject) -> UnsafeMutableRawPointer
{
    return UnsafeMutableRawPointer(Unmanaged.passRetained(object).toOpaque());
}


//Releases a pointer
public func ReleasePointer(_ pointer: UnsafeMutableRawPointer)
{
    Unmanaged<AnyObject>.fromOpaque(pointer).release();
}
