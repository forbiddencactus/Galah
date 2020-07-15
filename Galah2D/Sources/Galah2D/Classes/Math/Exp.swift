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

public func sqrt(_ x: Double) -> Double
{
    return Darwin.sqrt(x);
}

public func sqrtf(_ x: Float) -> Float
{
    return Darwin.sqrtf(x);
}

public func pow(_ base: Double, _ power: Double) -> Double
{
    return Darwin.pow(base, power);
}

public func powf(_ base: Float, _ power: Float) -> Float
{
    return Darwin.powf(base, power);
}

#endif
