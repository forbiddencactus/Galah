//
//  RenderQueue.swift
//  
//
//  Created by Alex Griffin on 11/2/20.
//


/*
 A RenderQueue represents an array of batched items that will be drawn on a particular frame. It's basically a frame command buffer of sorts.
 Platforms are supposed to implement the platform specific approach so as to push the information to the renderer as quickly as possible.
 There are (usually) three RenderQueues in our render pipeline.
*/

public protocol RenderQueue
{
    var QueuePointer: UnsafeMutableRawPointer { get };

    func IsClear() -> Bool;
    
    func BatchBufferSize() -> Int;
    func BatchBufferCount() -> Int;
    func ItemBufferSize() -> Int;
    func ItemBufferCount() -> Int;
    
    init();
    func PushBatch(_ texture: Texture) -> Int;
    
    func CanFitItems(_ itemCount: Int) -> Bool;
    func GrowItemBuffer(_ itemCount: Int);
    func CanFitBatches(_ batchCount: Int) -> Bool;
    func GrowBatchBuffer(_ batchCount: Int);

    //Returns batch relative position of item.
    func PushItemToRenderBatch(batchPosition: Int, itemPosition: Vec2, texturePosition: Vec2) -> Int;
    func GetBatchItemCount(_ batchPosition: Int) -> Int;
}
