/*
 https://developer.apple.com/documentation/metal/creating_and_sampling_textures
 https://donaldpinckney.com/metal/2018/07/05/metal-intro-1.html
 */
#import "Metal/MetalImpl.h"
#import "Metal/ShaderTypes.h"
#import "Common/Callback.h"

static const NSUInteger kMaxBuffersInFlight = 3;

static const size_t kAlignedUniformsSize = (sizeof(Uniforms) & ~0xFF) + 0x100;

@implementation MetalImpl
{
    MTKView* view;
    
    dispatch_semaphore_t _inFlightSemaphore;
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;

    id <MTLBuffer> _dynamicUniformBuffer;
    id <MTLRenderPipelineState> _pipelineState;
    id <MTLDepthStencilState> _depthState;
    MTLVertexDescriptor* _mtlVertexDescriptor;

    uint32_t _uniformBufferOffset;

    uint8_t _uniformBufferIndex;

    void* _uniformBufferAddress;
}

-(void) SetMetalKitView:(MTKView *)theView
{
    view = theView;
    
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

    NSUInteger uniformBufferSize = kAlignedUniformsSize * kMaxBuffersInFlight;

    _dynamicUniformBuffer = [_device newBufferWithLength:uniformBufferSize
                                                options:MTLResourceStorageModeShared];

    _dynamicUniformBuffer.label = @"UniformBuffer";

    _commandQueue = [_device newCommandQueue];
    
    //[self _loadAssets];
}

-(void) SetUpVertexDescriptor
{
    _mtlVertexDescriptor = [[MTLVertexDescriptor alloc] init];

    _mtlVertexDescriptor.attributes[VertexAttributePosition].format = MTLVertexFormatFloat3;
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
    _mtlVertexDescriptor.layouts[BufferIndexMeshGenerics].stepFunction = MTLVertexStepFunctionPerVertex;
}

-(void) SetUpPipelineState
{
    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

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

       if(renderPassDescriptor != nil) {

           /// Final pass rendering code here

           id <MTLRenderCommandEncoder> renderEncoder =
           [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
           renderEncoder.label = @"GalahRenderMetalEncoder";

           [renderEncoder pushDebugGroup:@"GalahRenderMetal2D"];

           [renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
           [renderEncoder setCullMode:MTLCullModeBack];
           [renderEncoder setRenderPipelineState:_pipelineState];
           [renderEncoder setDepthStencilState:_depthState];

           [renderEncoder setVertexBuffer:_dynamicUniformBuffer
                                   offset:_uniformBufferOffset
                                  atIndex:BufferIndexUniforms];

           [renderEncoder setFragmentBuffer:_dynamicUniformBuffer
                                     offset:_uniformBufferOffset
                                    atIndex:BufferIndexUniforms];

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

@end
