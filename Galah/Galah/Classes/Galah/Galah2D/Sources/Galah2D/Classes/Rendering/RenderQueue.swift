//
//  File.swift
//  
//
//  Created by Alex Griffin on 11/2/20.
//

import Foundation

/*
 A RenderQueue represents an array of batched items that will be drawn on a particular frame.
 Platforms are supposed to implement this in a platform-friendly way to minimise pushing around memory so as to feed verts and stuff
 in a renderer-friendly way.
*/

public protocol RenderQueue
{
    private var QueuePointer: UnsafeMutableRawPointer;

    public func IsClear() -> bool;
    
    public func BatchBufferSize() -> int;
    public func BatchBufferCount() -> int;
    public func ItemBufferSize() -> int;
    public func ItemBufferCount() -> int;
    
    init();
    public func PushBatch(_ texture: Texture) -> int;
    
    public func CanFitItems(_ itemCount: int) -> bool;
    public func GrowItemBuffer(_ itemCount: int);
    public func CanFitBatches(_ batchCount: int) -> bool;
    public func GrowBatchBuffer(_ batchCount: int);

    //Returns batch relative position of item.
    public func PushItemToRenderBatch(batchPosition: int, itemPosition: Vec2, texturePosition: Vec2) -> int;
    public func GetBatchItemCount(_ batchPosition: int) -> int;
}
