//
//  Exp.swift
//  Galah
//  Meant to wrap around the different ways of importing Math.h in Swift.
//  WIP as I need the various functions.
//
//  Created by Alex Griffin on 30/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

#if os(macOS) || os(iOS) //Darwin
import Darwin;

public func sqrt(x: Double) -> Double
{
    return Darwin.sqrt(x);
}

public func sqrtf(x: Float) -> Float
{
    return Darwin.sqrtf(x);
}

public func pow(base: Double, power: Double) -> Double
{
    return Darwin.pow(base, power);
}

public func powf(base: Float, power: Float) -> Float
{
    return Darwin.powf(base, power);
}

#endif
