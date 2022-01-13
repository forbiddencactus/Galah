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
// Rect types.

#ifndef galah_nativetypes_rect
#define galah_nativetypes_rect

#include "Vector.h"

typedef struct
{
    float width;
    float height;
} GSizef;

typedef struct
{
    GFloat2 tl;
    GFloat2 tr;
    GFloat2 bl;
    GFloat2 br;
} GQuadf;

#endif
