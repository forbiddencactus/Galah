//
//  Trig.swift
//  Galah
//  Meant to wrap around the different ways of importing Math.h in Swift.
//  WIP as I need the various functions.
//
//  Created by Alex Griffin on 30/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

#if os(macOS) || os(iOS) //Darwin
import Darwin;

public func sin(_ angleInRad: Double) -> Double
{
    return Darwin.sin(angleInRad);
}

public func sinf(_ angleInRad: Float) -> Float
{
    return Darwin.sinf(angleInRad);
}

public func cos(_ angleInRad: Double) -> Double
{
    return Darwin.cos(angleInRad);
}

public func cosf(_ angleInRad: Float) -> Float
{
    return Darwin.cosf(angleInRad);
}

public func tan(_ angleInRad: Double) -> Double
{
    return Darwin.tan(angleInRad);
}

public func tanf(_ angleInRad: Float) -> Float
{
    return Darwin.tanf(angleInRad);
}

//Inverse trig
public func atan(_ angleInRad: Double) -> Double
{
    return Darwin.atan(angleInRad);
}

public func atanf(_ angleInRad: Float) -> Float
{
    return Darwin.atanf(angleInRad);
}

public func atan2(_ y: Double,_ x: Double) -> Double
{
    return Darwin.atan2(y,x);
}

public func atan2f(_ y: Float,_ x: Float) -> Float
{
    return Darwin.atan2f(y,x);
}

#endif
