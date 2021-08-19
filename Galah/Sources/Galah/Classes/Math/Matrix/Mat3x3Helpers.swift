/*
MIT License

Copyright © 2020, 2021 Alexis Griffin.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

public struct Mat3x3Helpers
{
    private init() {}
    
    public static func CreateTranslation(translation: Float2) -> Mat3x3
    {
        return Mat3x3(
            m00: 1,
            m02: translation.x,
            m11: 1,
            m12: translation.y,
            m22: 1);
    }
    
    public static func CreateShear(shear: Float2) -> Mat3x3
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

    public static func CreateScale(scale: Float2) -> Mat3x3
    {
        return Mat3x3(
            m00: scale.x,
            m11: scale.y,
            m22: 1);
    }

    public static func CreateTRS(translation: Float2, rotationInRad: Float, scale: Float2) -> Mat3x3
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
    
    public static func CreateTRSS(translation: Float2, rotationInRad: Float, scale: Float2, shear: Float2) -> Mat3x3
    {
        return Mat3x3Helpers.CreateTranslation(translation: translation) *
            Mat3x3Helpers.CreateRotation(rotationInRad: rotationInRad) *
            Mat3x3Helpers.CreateScale(scale: scale) *
            Mat3x3Helpers.CreateShear(shear: shear);
    }

    public static func PositionFromTRS(_ m: Mat3x3) -> Float2
    {
        return Float2(m.m02, m.m12);
    }

    public static func RotationFromTRS(m: Mat3x3) -> Float
    {
        return atanf(-m.m01 / m.m11);
    }

    public static func ScaleFromTRS(m: Mat3x3) -> Float2
    {
        return Float2(sqrtf(powf(m.m00, 2) + powf(m.m10, 2)), sqrtf(powf(m.m01, 2) + powf(m.m11, 2)));
    }
}
