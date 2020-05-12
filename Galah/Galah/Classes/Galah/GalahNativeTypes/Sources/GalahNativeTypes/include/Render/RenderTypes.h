#ifndef galah_nativetypes_rendertypes
#define galah_nativetypes_rendertypes

#include "./Maths/Vector.h"
#include "./Maths/Matrices.h"

typedef struct
{
    NativeVec2f pos;
    NativeVec2f uv;
} NativeVert;

//There will be a buffer for each individual transform (matrix plus atlas index), buffer for atlas positions.
typedef struct
{
    NativeMat3x3 matrix;
    int texatlasindex;
} RenderQuad;

#endif
