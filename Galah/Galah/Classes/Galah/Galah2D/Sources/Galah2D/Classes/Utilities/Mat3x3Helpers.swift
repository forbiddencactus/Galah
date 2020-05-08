//
//  Mat3x3Utilities.swift
//  Galah
//
//  Created by Alex Griffin on 29/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

public struct Mat3x3Helpers
{
    private init() {}
    
    public static func CreateTranslation(translation: Vec2) -> Mat3x3
    {
        return Mat3x3(
            m00: 1,
            m02: translation.x,
            m11: 1,
            m12: translation.y,
            m22: 1);
    }
    
    public static func CreateShear(shear: Vec2) -> Mat3x3
    {
        return Mat3x3(m00: 1, m01: shear.x, m10: shear.y, m11: 1, m22: 1);
    }

    public static func CreateRotation(rotationInRad: Float) -> Mat3x3
    {
        let cosVal = cosf(rotationInRad);
        let sinVal = sinf(rotationInRad);

        return Mat3x3(
            m00: cosVal,
            m01: -sinVal,
            m10: sinVal,
            m11: cosVal,
            m22: 1);
    }

    public static func CreateScale(scale: Vec2) -> Mat3x3
    {
        return Mat3x3(
            m00: scale.x,
            m11: scale.y,
            m22: 1);
    }

    public static func CreateTRS(translation: Vec2, rotationInRad: Float, scale: Vec2) -> Mat3x3
    {
        let cosVal = cosf(rotationInRad);
        let sinVal = sinf(rotationInRad);

        return Mat3x3(
            m00: scale.x * cosVal,
            m01: scale.x * -sinVal,
            m02: translation.x,
            m10: scale.y * sinVal,
            m11: scale.y * cosVal,
            m12: translation.y,
            m20: 0,
            m21: 0,
            m22: 1);
    }
    
    public static func CreateTRSS(translation: Vec2, rotationInRad: Float, scale: Vec2, shear: Vec2) -> Mat3x3
    {
        return Mat3x3Helpers.CreateTranslation(translation: translation) *
            Mat3x3Helpers.CreateRotation(rotationInRad: rotationInRad) *
            Mat3x3Helpers.CreateScale(scale: scale) *
            Mat3x3Helpers.CreateShear(shear: shear);
    }

    public static func PositionFromTRS(_ m: Mat3x3) -> Vec2
    {
        return Vec2(m.m02, m.m12);
    }

    public static func RotationFromTRS(m: Mat3x3) -> Float
    {
        return atanf(-m.m01 / m.m11);
    }

    public static func ScaleFromTRS(m: Mat3x3) -> Vec2
    {
        return Vec2(sqrtf(powf(m.m00, 2) + powf(m.m10, 2)), sqrtf(powf(m.m01, 2) + powf(m.m11, 2)));
    }
}
