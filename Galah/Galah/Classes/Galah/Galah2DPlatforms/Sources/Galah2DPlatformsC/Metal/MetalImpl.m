/*
 https://developer.apple.com/documentation/metal/creating_and_sampling_textures
 https://donaldpinckney.com/metal/2018/07/05/metal-intro-1.html
 */
#import "Metal/MetalImpl.h"
#import "Metal/ShaderTypes.h"
#import "Common/Callback.h"
#import "Metal/MetalShaders.h"

static const NSUInteger kMaxBuffersInFlight = 3;

@implementation MetalImpl
{
    MTKView* view;
    MTLClearColor clearColour;
    
    dispatch_semaphore_t _inFlightSemaphore;
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;

    id <MTLRenderPipelineState> _pipelineState;
    id <MTLDepthStencilState> _depthState;
    MTLVertexDescriptor* _mtlVertexDescriptor;

    uint32_t _uniformBufferOffset;

    uint8_t _uniformBufferIndex;

    void* _uniformBufferAddress;
    
    vector_uint2 _viewportSize;
}

-(id<MTLBuffer>) RequestBufferWithLabel:(NSString*) label length:(NSUInteger) length
{
    id<MTLBuffer> textureBuffer;

    textureBuffer = [_device newBufferWithLength: length options:MTLResourceStorageModeShared];
    
    textureBuffer.label = label;
    
    return textureBuffer;
}

-(void) FreeBuffer:(id<MTLBuffer>) buff
{
    //buff free
}

-(void) SetMetalKitView:(MTKView *)theView;
{
    view = theView;
    _viewportSize.y = 1080;
    _viewportSize.x = 1920;
    
    clearColour = MTLClearColorMake(0, 0, 0, 1);
    
    view.delegate = self;
    [view setPaused: true];
    view.enableSetNeedsDisplay = false;
    
    _device = view.device;
    _inFlightSemaphore = dispatch_semaphore_create(kMaxBuffersInFlight);
    
    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    view.sampleCount = 1;
    

    [self SetUpVertexDescriptor];
    [self SetUpPipelineState];

    MTLDepthStencilDescriptor *depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthStateDesc.depthWriteEnabled = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];

    _commandQueue = [_device newCommandQueue];
    
    //[self _loadAssets];
}

-(void) SetUpVertexDescriptor
{
    _mtlVertexDescriptor = [[MTLVertexDescriptor alloc] init];

    /*_mtlVertexDescriptor.attributes[VertexAttributePosition].format = MTLVertexFormatFloat3;
    _mtlVertexDescriptor.attributes[VertexAttributePosition].offset = 0;
    _mtlVertexDescriptor.attributes[VertexAttributePosition].bufferIndex = BufferIndexMeshPositions;

    _mtlVertexDescriptor.attributes[VertexAttributeTexcoord].format = MTLVertexFormatFloat2;
    _mtlVertexDescriptor.attributes[VertexAttributeTexcoord].offset = 0;
    _mtlVertexDescriptor.attributes[VertexAttributeTexcoord].bufferIndex = BufferIndexMeshGenerics;

    _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stride = 12;
    _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stepRate = 1;
    _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stepFunction = MTLVertexStepFunctionPerVertex;

    _mtlVertexDescriptor.layouts[BufferIndexMeshGenerics].stride = 8;
    _mtlVertexDescriptor.layouts[BufferIndexMeshGenerics].stepRate = 1;
    _mtlVertexDescriptor.layouts[BufferIndexMeshGenerics].stepFunction = MTLVertexStepFunctionPerVertex;*/
}

-(void) SetUpPipelineState
{
    NSError* shaderError = nil;
    id<MTLLibrary> defaultLibrary = [_device newLibraryWithSource:shader() options:nil error:&shaderError];
    
    if(!defaultLibrary) {
        [NSException raise:@"Failed to compile shaders" format:@"%@", [shaderError localizedDescription]];
    }

    id <MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];

    id <MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];

    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"MetalPipeline";
    pipelineStateDescriptor.sampleCount = view.sampleCount;
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.vertexDescriptor = _mtlVertexDescriptor;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat;

    NSError *error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState)
    {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
}

-(void)Draw
{
    [view draw];
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);

       id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
       commandBuffer.label = @"GalahRenderMetal";

       __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
       [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer)
        {
            dispatch_semaphore_signal(block_sema);
        }];

       //[self _updateDynamicBufferState];

       //[self _updateGameState];

       /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
       ///   holding onto the drawable and blocking the display pipeline any longer than necessary
       MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    
        //https://gamedev.stackexchange.com/questions/69835/batching-and-z-order-with-alpha-blending-in-a-3d-world
    
       if(renderPassDescriptor != nil) {

           /// Final pass rendering code here

           [renderPassDescriptor.colorAttachments objectAtIndexedSubscript:0].clearColor = clearColour;
           id <MTLRenderCommandEncoder> renderEncoder =
           [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
           renderEncoder.label = @"GalahRenderMetalEncoder";

           [renderEncoder pushDebugGroup:@"GalahRenderMetal2D"];

           [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0 }];
           [renderEncoder setRenderPipelineState:_pipelineState];
           [renderEncoder setDepthStencilState:_depthState];

           [renderEncoder setRenderPipelineState:_pipelineState];
           
           //Render textures
           for(int i = 0; i < 0; i++)
           {
               void* test;
               id<MTLTexture> texture = (__bridge id<MTLTexture>)test;
               
               //textureBuffer.contents * = verts;
               
               //[renderEncoder setVertexBuffer:textureBuffer offset:0 atIndex:AAPLVertexInputIndexVertices];

               [renderEncoder setVertexBytes:&_viewportSize
                                      length:sizeof(_viewportSize)
                                     atIndex:AAPLVertexInputIndexViewportSize];

               // Set the texture object.  The AAPLTextureIndexBaseColor enum value corresponds
               ///  to the 'colorMap' argument in the 'samplingShader' function because its
               //   texture attribute qualifier also uses AAPLTextureIndexBaseColor for its index.
               [renderEncoder setFragmentTexture:texture
                                         atIndex:AAPLTextureIndexBaseColor];

               // Draw the triangles.
               [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                                 vertexStart:0
                                 vertexCount:6];
               
           }

                  

           
           /*
           for (NSUInteger bufferIndex = 0; bufferIndex < _mesh.vertexBuffers.count; bufferIndex++)
           {
               MTKMeshBuffer *vertexBuffer = _mesh.vertexBuffers[bufferIndex];
               if((NSNull*)vertexBuffer != [NSNull null])
               {
                   [renderEncoder setVertexBuffer:vertexBuffer.buffer
                                           offset:vertexBuffer.offset
                                          atIndex:bufferIndex];
               }
           }

           [renderEncoder setFragmentTexture:_colorMap
                                     atIndex:TextureIndexColor];

           for(MTKSubmesh *submesh in _mesh.submeshes)
           {
               [renderEncoder drawIndexedPrimitives:submesh.primitiveType
                                         indexCount:submesh.indexCount
                                          indexType:submesh.indexType
                                        indexBuffer:submesh.indexBuffer.buffer
                                  indexBufferOffset:submesh.indexBuffer.offset];
           }
            */

           [renderEncoder popDebugGroup];

           [renderEncoder endEncoding];

           [commandBuffer presentDrawable:view.currentDrawable];
       }

       [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    BridgeSize cSize;
    cSize.width = size.width;
    cSize.height = size.height;
    
    viewSizeChangedCallback(cSize);
}

- (void) SetClearColour:(float)r green:(float)g blue:(float)b alpha:(float)a
{
    clearColour = MTLClearColorMake(r, g, b, a);
}

-(void) SetViewportSize:(int) width height:(int) height
{
    _viewportSize.x = width;
    _viewportSize.y = height;
}

@end
