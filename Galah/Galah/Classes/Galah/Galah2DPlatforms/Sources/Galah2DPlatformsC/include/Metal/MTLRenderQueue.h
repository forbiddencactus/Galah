#ifndef MTLRenderQueue_h
#define MTLRenderQueue_h

#include "Common/Texture.h"
#include "Common/Rects.h"
#include "ShaderTypes.h"

/*
 Basic layout:
 Buffer of 1024 RenderItems
 Buffer of 128 RenderBatches
 
 They can each grow by allocating a bigger buffer if space runs out.
 */

/*
 WARNING: THIS CODE HAS BASICALLY NO OVERFLOW CHECKS OF ANY SORT OR ANYTHING. IT'LL BLAST MEMORY AND CREATE SADNESS IF USED WRONG.
 The correct usage for this system is to grow/assign/allocate the buffers based on draworder. So, a batch should have an idea of how many
 RenderItems in the buffer it will need before a new batch is created, etc. Otherwise we run the risk of a batch overflowing into another batch.
*/

//TODO: Place asserts around the implementation of this to check for basic overflow fun.

#define MTLRENDERQUEUE_DEFAULT_RENDERITEM_SIZE = 1024
#define MTLRENDERQUEUE_DEFAULT_RENDERBATCH_SIZE = 128

@class MetalImpl;
@protocol MTLBuffer;

typedef struct
{
    AAPLVertex verts[6];
}   RenderItem;

typedef struct
{
    RenderItem* buffer;
    int count;
    Texture* Texture;
}   RenderBatch;

typedef struct
{
    MetalImpl* renderer;
    
    id<MTLBuffer> itemBuffer;
    int itemCount;
    int itemSize;
    
    RenderBatch* batchBuffer;
    int batchCount;
    int batchSize;
    
}   RenderQueue;

//itemBuffSize and renderBatchBuffSize allocate the initial size of the buffer based on multiples of the default size. So a reasonable 'initial' value is 1.
RenderQueue* renderqueue_new(MetalImpl* renderer, int itemBuffSize, int renderBatchBuffSize);
RenderQueue* renderqueue_new(MetalImpl* renderer);

void renderqueue_clear(RenderQueue* queue);
bool renderqueue_isclear(RenderQueue* queue);

int renderqueue_push_batch(RenderQueue* queue, Texture* texture);
RenderBatch* renderqueue_get_batch(RenderQueue* queue, int position);

bool renderqueue_can_fit_items(RenderQueue* queue, int itemCount);
void renderqueue_grow_items(RenderQueue* queue, int itemCount);
bool renderqueue_can_fit_batches(RenderQueue* queue, int batchCount);
void renderqueue_grow_batches(RenderQueue* queue, int batchCount);

//Returns batch relative position of item. 
int renderbatch_push_renderitem(RenderQueue* queue, int batchPos, Vec2 pos, GRect tex);
RenderItem* renderbatch_get_renderitem(RenderQueue* queue, int batchPos, int position);

#endif

