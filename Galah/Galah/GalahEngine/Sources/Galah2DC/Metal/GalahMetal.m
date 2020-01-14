#include "Metal/GalahMetal.h"

void set_mtkview(MetalRenderer* renderer, metalview* view)
{
    MetalImpl* render = (__bridge MetalImpl*) renderer->renderer;
    [render SetMetalKitView:(__bridge MTKView *)(view)];
}

MetalRenderer construct_renderer()
{
    MetalImpl* renderer = [[MetalImpl alloc] init];
    MetalRenderer returnRender;
    returnRender.renderer = CFBridgingRetain(renderer);
    
    return returnRender;
}

void renderer_draw(MetalRenderer* renderer)
{
    MetalImpl* render = (__bridge MetalImpl*) renderer->renderer;
    [render Draw];
}

void renderer_setclearcolour(MetalRenderer* renderer, float r, float g, float b, float a)
{
    MetalImpl* render = (__bridge MetalImpl*) renderer->renderer;
    [render SetClearColour:r green:g blue:b alpha:a];
}
