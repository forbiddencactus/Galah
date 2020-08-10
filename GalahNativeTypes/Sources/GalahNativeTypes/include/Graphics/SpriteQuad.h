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
} NativeTexPoint2D;

typedef struct
{
    NativeVert vert[6];
} NativeTexQuad2D;

#endif
