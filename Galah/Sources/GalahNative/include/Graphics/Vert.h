//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020, 2021, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// Vert types.

#ifndef galah_nativetypes_rendervert
#define galah_nativetypes_rendervert

#include "./Maths/Vector.h"
#include "./Maths/Matrices.h"

typedef struct
{
    GFloat2 pos;
    GFloat2 uv;
} GVert;

#endif
