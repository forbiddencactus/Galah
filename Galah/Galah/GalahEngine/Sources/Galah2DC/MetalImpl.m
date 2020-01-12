#import "Metal/MetalImpl.h"

@implementation MetalImpl

-(void) SetMetalKitView:(MTKView *)theView
{
    self->theView = theView;
    
    theView.delegate = self;
    [theView setPaused: true];
    theView.enableSetNeedsDisplay = false;
}

-(void)Draw
{
    [self->theView draw];
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

@end
