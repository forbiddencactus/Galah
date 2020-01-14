#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface MetalImpl: NSObject <MTKViewDelegate>


-(void) SetMetalKitView:(MTKView*) theView;
-(void) Draw;
@end
