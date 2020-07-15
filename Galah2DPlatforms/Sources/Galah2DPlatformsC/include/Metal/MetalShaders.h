#if !defined(_STRINGIFY)
#define __STRINGIFY( _x )   # _x
#define _STRINGIFY( _x )   __STRINGIFY( _x )
#endif

typedef NSString *(^StringifyArrayOfIncludes)(NSArray <NSString *> *includes);
static NSString *(^stringifyHeaderFileNamesArray)(NSArray <NSString *> *) = ^(NSArray <NSString *> *includes) {
    NSMutableString *importStatements = [NSMutableString new];
    [includes enumerateObjectsUsingBlock:^(NSString * _Nonnull include, NSUInteger idx, BOOL * _Nonnull stop) {
        [importStatements appendString:@"#include <"];
        [importStatements appendString:include];
        [importStatements appendString:@">\n"];
    }];

    return [NSString new];
};

typedef NSString *(^StringifyArrayOfHeaderFileNames)(NSArray <NSString *> *headerFileNames);
static NSString *(^stringifyIncludesArray)(NSArray *) = ^(NSArray *headerFileNames) {
    NSMutableString *importStatements = [NSMutableString new];
    [headerFileNames enumerateObjectsUsingBlock:^(NSString * _Nonnull headerFileName, NSUInteger idx, BOOL * _Nonnull stop) {
        [importStatements appendString:@"#import "];
        [importStatements appendString:@_STRINGIFY("")];
        [importStatements appendString:headerFileName];
        [importStatements appendString:@_STRINGIFY("")];
        [importStatements appendString:@"\n"];
    }];

    return [NSString new];
};

NSString* shader()
{
    NSString *includes = stringifyIncludesArray(@[@"metal_stdlib", @"simd/simd.h"]);
    NSString *imports  = stringifyHeaderFileNamesArray(@[@"Metal/ShaderTypes.h"]);
    NSString *code     = [NSString stringWithFormat:@"%s",
                          _STRINGIFY(
                            using namespace metal;

                            typedef struct
                            {
                                // Positions in pixel space. A value of 100 indicates 100 pixels from the origin/center.
                                vector_float2 position;

                                // 2D texture coordinate
                                vector_float2 textureCoordinate;
                            } Vertex;
                            
                            typedef struct
                            {
                                float4 position [[position]];
                                float2 texCoord;
                            } ColorInOut;

                            vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                                                           constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
                            {
                                ColorInOut out;

                                float4 position = float4(in.position, 1.0);
                                out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
                                out.texCoord = in.texCoord;

                                return out;
                            }

                            fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                                                           constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                                                           texture2d<half> colorMap     [[ texture(TextureIndexColor) ]])
                            {
                                constexpr sampler colorSampler(mip_filter::linear,
                                                               mag_filter::linear,
                                                               min_filter::linear);

                                half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);

                                return float4(colorSample);
                            }


                                     )];

    return [NSString stringWithFormat:@"%@\n%@\n%@", includes, imports, code];
}
