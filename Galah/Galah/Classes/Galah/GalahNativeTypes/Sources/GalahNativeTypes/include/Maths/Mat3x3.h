#ifndef galah_nativetypes_mat3x3
#define galah_nativetypes_mat3x3

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
