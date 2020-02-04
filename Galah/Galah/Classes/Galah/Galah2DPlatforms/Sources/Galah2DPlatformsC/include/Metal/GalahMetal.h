#ifndef Metal_h
#define Metal_h

#include "MetalImpl.h"

void set_mtkview(MetalImpl* renderer, MTKView* view);
MetalImpl* construct_renderer();
void renderer_draw(MetalImpl* renderer);
void renderer_setclearcolour(MetalImpl* renderer, float r, float g, float b, float a);
void renderer_setviewportsize(MetalImpl* renderer, int width, int height);
#endif 
