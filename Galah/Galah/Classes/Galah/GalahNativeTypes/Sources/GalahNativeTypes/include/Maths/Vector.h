#ifndef galah_nativetypes_vector
#define galah_nativetypes_vector

typedef struct __attribute__((__aligned__(8)))
{
    float x;
    float y;
} NativeVec2f;

typedef struct __attribute__((__aligned__(16)))
{
    float x;
    float y;
    float z;
} NativeVec3f;

#endif
