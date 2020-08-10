#ifndef galah_nativetypes_vector
#define galah_nativetypes_vector

typedef struct __attribute__((__aligned__(8)))
{
    float x;
    float y;
} NativeFloat2;

typedef struct __attribute__((__aligned__(16)))
{
    float x;
    float y;
    float z;
} NativeFloat3;

typedef struct __attribute__((__aligned__(16)))
{
    float x;
    float y;
    float z;
    float w;
} NativeFloat4;

#endif
