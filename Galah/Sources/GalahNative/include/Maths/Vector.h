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
// Vectors.

#ifndef galah_nativetypes_vector
#define galah_nativetypes_vector

typedef struct __attribute__((__aligned__(8)))
{
    float x;
    float y;
} GFloat2;

typedef struct __attribute__((__aligned__(16)))
{
    float x;
    float y;
    float z;
} GFloat3;

typedef struct __attribute__((__aligned__(16)))
{
    float x;
    float y;
    float z;
    float w;
} GFloat4;

#endif
