#ifndef Metal_h
#define Metal_h

#include "MetalImpl.h"

typedef void renderer, metalview;

typedef struct MetalRenderer {
    renderer* renderer;
} MetalRenderer;

void set_mtkview(MetalRenderer* renderer, metalview* view);
MetalRenderer construct_renderer();
void renderer_draw(MetalRenderer* renderer);

#endif 
