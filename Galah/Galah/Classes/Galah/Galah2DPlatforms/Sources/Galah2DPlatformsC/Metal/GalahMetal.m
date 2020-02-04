#include "Metal/GalahMetal.h"

void set_mtkview(MetalImpl* renderer, MTKView* view)
{
    [renderer SetMetalKitView:view];
}

MetalImpl* construct_renderer()
{
    MetalImpl* renderer = [[MetalImpl alloc] init];
    
    return renderer;
}

void renderer_draw(MetalImpl* renderer)
{
    [renderer Draw];
}

void renderer_setclearcolour(MetalImpl* renderer, float r, float g, float b, float a)
{
    [renderer SetClearColour:r green:g blue:b alpha:a];
}

void renderer_setviewportsize(MetalImpl* renderer, int width, int height)
{
    [renderer SetViewportSize:width height:height];
}
