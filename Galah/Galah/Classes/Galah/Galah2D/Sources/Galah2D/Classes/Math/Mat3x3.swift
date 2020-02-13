//
//  Mat3x3.swift
//  Galah
//
//  Created by Alex Griffin on 29/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

public struct Mat3x3
{
    var m00: Float = 0;
    var m01: Float = 0;
    var m02: Float = 0;
    var m10: Float = 0;
    var m11: Float = 0;
    var m12: Float = 0;
    var m20: Float = 0;
    var m21: Float = 0;
    var m22: Float = 0;

    init(m00: Float = 0,
         m01: Float = 0,
         m02: Float = 0,
         m10: Float = 0,
         m11: Float = 0,
         m12: Float = 0,
         m20: Float = 0,
         m21: Float = 0,
         m22: Float = 0)
    {
        self.m00 = m00;
        self.m10 = m10;
        self.m20 = m20;
        self.m01 = m01;
        self.m11 = m11;
        self.m21 = m21;
        self.m02 = m02;
        self.m12 = m12;
        self.m22 = m22;
    }
    
    init(_ m: Mat3x3)
    {
        self.m00 = m.m00;
        self.m10 = m.m10;
        self.m20 = m.m20;
        self.m01 = m.m01;
        self.m11 = m.m11;
        self.m21 = m.m21;
        self.m02 = m.m02;
        self.m12 = m.m12;
        self.m22 = m.m22;
    }

    static var Identity: Mat3x3
    {
        get
        {
            return Mat3x3(m00:1, m11:1, m22: 1);
        }
    }


    public func GetDeterminant() -> Float
    {
        return m00 * (m11 * m22 - m12 * m21)
        - m01 * (m10 * m22 - m12 * m20)
        + m02 * (m10 * m21 - m11 * m20);
    }

    public func Invert() throws -> Mat3x3
    {
        let determinant: Float = GetDeterminant();

        if (determinant == 0)
        {
            throw Mat3x3Error.ErrorMessage(message: "Can't invert matrix with determinant 0");
        }

        let invdet: Float = 1.0 / determinant;

        return Mat3x3(
            m00: (m11 * m22 - m21 * m12) * invdet,
            m01: (m21 * m02 - m01 * m22) * invdet,
            m02: (m01 * m12 - m11 * m02) * invdet,
            m10: (m20 * m12 - m10 * m22) * invdet,
            m11: (m00 * m22 - m20 * m02) * invdet,
            m12: (m10 * m02 - m00 * m12) * invdet,
            m20: (m10 * m21 - m20 * m11) * invdet,
            m21: (m20 * m01 - m00 * m21) * invdet,
            m22: (m00 * m11 - m10 * m01) * invdet);
    }

    public func Transpose() -> Mat3x3
    {
        return Mat3x3(
            m00: m00,
            m01: m10,
            m02: m20,
            m10: m01,
            m11: m11,
            m12: m21,
            m20: m02,
            m21: m12,
            m22: m22);
    }

    public static func MultiplyFVec2(m: Mat3x3, vec: FVec2) -> FVec2
    {
        return FVec2(
            m.m00 * vec.x + m.m01 * vec.y + m.m02,
            m.m10 * vec.x + m.m11 * vec.y + m.m12);
    }

    public static func MultiplyMat3x3(m1: Mat3x3, m2: Mat3x3) -> Mat3x3
    {
        return Mat3x3(
            m00: m1.m00 * m2.m00 + m1.m10 * m2.m01 + m1.m20 * m2.m02,
            m01: m1.m01 * m2.m00 + m1.m11 * m2.m01 + m1.m21 * m2.m02,
            m02: m1.m02 * m2.m00 + m1.m12 * m2.m01 + m1.m22 * m2.m02,
            m10: m1.m00 * m2.m10 + m1.m10 * m2.m11 + m1.m20 * m2.m12,
            m11: m1.m01 * m2.m10 + m1.m11 * m2.m11 + m1.m21 * m2.m12,
            m12: m1.m02 * m2.m10 + m1.m12 * m2.m11 + m1.m22 * m2.m12,
            m20: m1.m00 * m2.m20 + m1.m10 * m2.m21 + m1.m20 * m2.m22,
            m21: m1.m01 * m2.m20 + m1.m11 * m2.m21 + m1.m21 * m2.m22,
            m22: m1.m02 * m2.m20 + m1.m12 * m2.m21 + m1.m22 * m2.m22);
    }

    public static func *(lhs: Mat3x3, rhs: Mat3x3) -> Mat3x3
    {
        return Mat3x3.MultiplyMat3x3(m1: lhs, m2: rhs);
    }

    public static func *(lhs: Mat3x3, rhs: FVec2) -> FVec2
    {
        return Mat3x3.MultiplyFVec2(m: lhs, vec: rhs);
    }
    
    enum Mat3x3Error: Error
    {
        case ErrorMessage(message: String);
    }
}

