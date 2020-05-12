#ifndef galah_nativetypes_matrices
#define galah_nativetypes_matrices

//Column major matrix.
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
} NativeMat3x3;

#endif
