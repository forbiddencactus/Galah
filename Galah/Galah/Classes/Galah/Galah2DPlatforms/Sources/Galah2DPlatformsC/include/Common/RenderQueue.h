#ifndef RenderQueue_h
#define RenderQueue_h

#include "Texture.h"

typedef struct
{
    int PositionX;
    int PositionY;
    Texture* Texture;
} RenderItem;

typedef struct
{
    RenderItem * buffer;
    int count;
} RenderQueue;

#endif

