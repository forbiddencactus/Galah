#ifndef galah_nativetypes_matrices
#define galah_nativetypes_matrices

//Column major matrices.
typedef struct __attribute__((__aligned__(16)))
{
    float m00;
    float m10;
    float m20;
    float m01;
    float m11;
    float m21;
    float m02;
    float m12;
    float m22;
} NativeFloat3x3;

typedef struct __attribute__((__aligned__(16)))
{
    float m00;
    float m10;
    float m20;
    float m30;
    float m01;
    float m11;
    float m21;
    float m31;
    float m02;
    float m12;
    float m22;
    float m32;
    float m03;
    float m13;
    float m23;
    float m33;
} NativeFloat4x4;
#endif
