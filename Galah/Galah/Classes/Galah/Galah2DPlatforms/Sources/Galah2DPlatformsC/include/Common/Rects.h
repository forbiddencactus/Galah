#ifndef Rects_h
#define Rects_h

typedef struct
{
    float x;
    float y;
} Vec2;

typedef struct
{
    float width;
    float height;
} GSize;

typedef struct
{
    Vec2 pos;
    GSize size;
} GRect;

#endif
