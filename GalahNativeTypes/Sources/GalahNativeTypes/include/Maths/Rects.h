#ifndef galah_nativetypes_rect
#define galah_nativetypes_rect

#include "Vector.h"

typedef struct
{
    float width;
    float height;
} NativeSize;

typedef struct
{
    float tl;
    float tr;
    float bl;
    float br;
} NativeQuad;

#endif
