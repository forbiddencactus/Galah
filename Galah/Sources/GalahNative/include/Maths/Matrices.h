//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020 - 2022, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// Matrices.

#ifndef galah_nativetypes_matrices
#define galah_nativetypes_matrices

//Column major matrices.
typedef struct __attribute__((__aligned__(16)))
{
    float m00;
    float m10;
    float m20;
    float m01;
    float m11;
    float m21;
    float m02;
    float m12;
    float m22;
} GFloat3x3;

typedef struct __attribute__((__aligned__(16)))
{
    float m00;
    float m10;
    float m20;
    float m30;
    float m01;
    float m11;
    float m21;
    float m31;
    float m02;
    float m12;
    float m22;
    float m32;
    float m03;
    float m13;
    float m23;
    float m33;
} GFloat4x4;

#endif
