#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface MetalImpl: NSObject <MTKViewDelegate>


-(void) SetMetalKitView:(MTKView*) theView;
-(void) Draw;
-(void) SetClearColour:(float) r green: (float) g blue: (float) b alpha:(float) a;
-(void) SetViewportSize:(int) width height:(int) height;
@end
