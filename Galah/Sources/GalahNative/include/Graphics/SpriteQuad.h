//---- Galah Engine---------------------------------------------------------//
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
// Textured quad types.

#ifndef galah_nativetypes_renderspritequad
#define galah_nativetypes_renderspritequad

#include "Maths/Vector.h"
#include "Maths/Matrices.h"
#include "Vert.h"

//There will be a buffer for each individual transform (matrix plus atlas index), buffer for atlas positions.
//This is a chonky piece of data because we'll essentially have two rendering pathways - one for culling and one without.
//Ideally our renderqueue will be smart enough to know when to prepopulate things when. 
typedef struct
{
    NativeFloat3x3 matrix;
    int texatlasindex;    
} GTexPoint2D;

typedef struct
{
    GVert vert[6];
} GTexQuad2D;

#endif
