#ifndef galah_nativetypes_rect
#define galah_nativetypes_rect

#include "Vector.h"

typedef struct
{
    float width;
    float height;
} Size;

typedef struct
{
    float tl;
    float tr;
    float bl;
    float br;
} Quad;

#endif
