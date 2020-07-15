//
//  Mat3x3.swift
//  Galah
//
//  Created by Alex Griffin on 29/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

import GalahNativeTypes;

public struct Mat3x3
{
    //Column major.
    private var mat: NativeMat3x3;
    @inline(__always) public var m00: Float { get { return mat.m00; } set { mat.m00 = newValue; } };
    @inline(__always) public var m01: Float { get { return mat.m01; } set { mat.m01 = newValue; } };
    @inline(__always) public var m02: Float { get { return mat.m02; } set { mat.m02 = newValue; } };
    @inline(__always) public var m10: Float { get { return mat.m10; } set { mat.m10 = newValue; } };
    @inline(__always) public var m11: Float { get { return mat.m11; } set { mat.m11 = newValue; } };
    @inline(__always) public var m12: Float { get { return mat.m12; } set { mat.m12 = newValue; } };
    @inline(__always) public var m20: Float { get { return mat.m20; } set { mat.m20 = newValue; } };
    @inline(__always) public var m21: Float { get { return mat.m21; } set { mat.m21 = newValue; } };
    @inline(__always) public var m22: Float { get { return mat.m22; } set { mat.m22 = newValue; } };

    

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
        self.mat = NativeMat3x3();
        self.mat.m00 = m00;
        self.mat.m10 = m10;
        self.mat.m20 = m20;
        self.mat.m01 = m01;
        self.mat.m11 = m11;
        self.mat.m21 = m21;
        self.mat.m02 = m02;
        self.mat.m12 = m12;
        self.mat.m22 = m22;
    }
    
    init(_ m: Mat3x3)
    {
        self.mat = NativeMat3x3();
        self.mat.m00 = m.m00;
        self.mat.m10 = m.m10;
        self.mat.m20 = m.m20;
        self.mat.m01 = m.m01;
        self.mat.m11 = m.m11;
        self.mat.m21 = m.m21;
        self.mat.m02 = m.m02;
        self.mat.m12 = m.m12;
        self.mat.m22 = m.m22;
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
        return mat.m00 * (mat.m11 * mat.m22 - mat.m12 * mat.m21)
            - mat.m01 * (mat.m10 * mat.m22 - mat.m12 * mat.m20)
            + mat.m02 * (mat.m10 * mat.m21 - mat.m11 * mat.m20);
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
            m00: (mat.m11 * mat.m22 - mat.m21 * mat.m12) * invdet,
            m01: (mat.m21 * mat.m02 - mat.m01 * mat.m22) * invdet,
            m02: (mat.m01 * mat.m12 - mat.m11 * mat.m02) * invdet,
            m10: (mat.m20 * mat.m12 - mat.m10 * mat.m22) * invdet,
            m11: (mat.m00 * mat.m22 - mat.m20 * mat.m02) * invdet,
            m12: (mat.m10 * mat.m02 - mat.m00 * mat.m12) * invdet,
            m20: (mat.m10 * mat.m21 - mat.m20 * mat.m11) * invdet,
            m21: (mat.m20 * mat.m01 - mat.m00 * mat.m21) * invdet,
            m22: (mat.m00 * mat.m11 - mat.m10 * mat.m01) * invdet);
    }

    public func Transpose() -> Mat3x3
    {
        return Mat3x3(
            m00: mat.m00,
            m01: mat.m10,
            m02: mat.m20,
            m10: mat.m01,
            m11: mat.m11,
            m12: mat.m21,
            m20: mat.m02,
            m21: mat.m12,
            m22: mat.m22);
    }

    public static func MultiplyVec2(m: Mat3x3, vec: Vec2) -> Vec2
    {
        return Vec2(
            m.mat.m00 * vec.x + m.mat.m01 * vec.y + m.mat.m02,
            m.mat.m10 * vec.x + m.mat.m11 * vec.y + m.mat.m12);
    }

    public static func MultiplyMat3x3(m1: Mat3x3, m2: Mat3x3) -> Mat3x3
    {
        return Mat3x3(
            m00: m1.mat.m00 * m2.mat.m00 + m1.mat.m10 * m2.mat.m01 + m1.mat.m20 * m2.mat.m02,
            m01: m1.mat.m01 * m2.mat.m00 + m1.mat.m11 * m2.mat.m01 + m1.mat.m21 * m2.mat.m02,
            m02: m1.mat.m02 * m2.mat.m00 + m1.mat.m12 * m2.mat.m01 + m1.mat.m22 * m2.mat.m02,
            m10: m1.mat.m00 * m2.mat.m10 + m1.mat.m10 * m2.mat.m11 + m1.mat.m20 * m2.mat.m12,
            m11: m1.mat.m01 * m2.mat.m10 + m1.mat.m11 * m2.mat.m11 + m1.mat.m21 * m2.mat.m12,
            m12: m1.mat.m02 * m2.mat.m10 + m1.mat.m12 * m2.mat.m11 + m1.mat.m22 * m2.mat.m12,
            m20: m1.mat.m00 * m2.mat.m20 + m1.mat.m10 * m2.mat.m21 + m1.mat.m20 * m2.mat.m22,
            m21: m1.mat.m01 * m2.mat.m20 + m1.mat.m11 * m2.mat.m21 + m1.mat.m21 * m2.mat.m22,
            m22: m1.mat.m02 * m2.mat.m20 + m1.mat.m12 * m2.mat.m21 + m1.mat.m22 * m2.mat.m22);
    }

    public static func *(lhs: Mat3x3, rhs: Mat3x3) -> Mat3x3
    {
        return Mat3x3.MultiplyMat3x3(m1: lhs, m2: rhs);
    }

    public static func *(lhs: Mat3x3, rhs: Vec2) -> Vec2
    {
        return Mat3x3.MultiplyVec2(m: lhs, vec: rhs);
    }
    
    enum Mat3x3Error: Error
    {
        case ErrorMessage(message: String);
    }
}

