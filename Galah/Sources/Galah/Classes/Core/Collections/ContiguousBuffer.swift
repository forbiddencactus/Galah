//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020 - 2022, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// A contiguous buffer allocated on the heap containing elements of a particular type.

import Swift;
import GalahNative.Memory;
import GalahNative.Settings;

// Unboxed, no copy on write.
struct BufferCore
{
    let type: Any.Type;

    var Buffer: GBuffer;
    var BufferData: GBufferData
    {
        get
        {
            var bufCpy = Buffer;
            return buffer_get_data(&bufCpy).pointee;
        }
    }
    
    let BufferResizedEvent = PtrEvent<BufferCore>();
    let BufferElementsMovedEvent = PtrEvent<BufferCore>();
    
    // Inits this buffer.
    init(withInitialCapacity: Int, withType: Any.Type) throws
    {
        type = withType;
        let sizeOf: Int = ExtentsOf(withType);
        Buffer = buffer_create(sizeOf, GUInt(withInitialCapacity), true);
        
        if(Buffer.bufferPtr == nil)
        {
            throw ContiguousMutableBufferError.AllocError;
        }

        buffer_addresizecallback(&Buffer, OnBufferResized,  unsafeBitCast(self, to: UnsafeMutableRawPointer.self));
        buffer_addelementsmovedcallback(&Buffer, OnBufferElementsMoved, unsafeBitCast(self, to: UnsafeMutableRawPointer.self));
    }
    
    // Inits this buffer with a copy of the supplied buffer. Events are copied as-is.
    init(withCopyOf: inout BufferCore, withExtraCapacityCount: Int = 0) throws
    {
        type = withCopyOf.type;
        Buffer = buffer_create_with_copy(&withCopyOf.Buffer);
        
        if(Buffer.bufferPtr == nil)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
        
        buffer_addresizecallback(&Buffer, OnBufferResized, unsafeBitCast(self, to: UnsafeMutableRawPointer.self));
        buffer_addelementsmovedcallback(&Buffer, OnBufferElementsMoved, unsafeBitCast(self, to: UnsafeMutableRawPointer.self));
    }
    
    // Callback for when a buffer resizes.
    func BufferResized()
    {
        
    }
    
    // Callback for when a buffer's elements move.
    func BufferElementsMoved()
    {
        
    }
}

internal protocol GBufferProtocol: Boxable
{
    // The type the buffer will work with. Not always the type of the object contained!
    associatedtype WorkingBufferType;
    
    var Base: BufferCore { get set}
}

internal extension GBufferProtocol
{
    // The number of elements in the buffer.
    var Count: Int { get { return Int(Base.BufferData.count); } };
    
    // The capacity of the buffer.
    var Capacity: UInt { get { return UInt(Base.BufferData.capacity); } };
    
    // Whether the buffer full auto resize once it is at capacity.
    var Mutable: Bool { get { return Base.BufferData.isAutoResize; } };
    
    // Returns the type that this buffer stores.
    var ElementType: Any.Type { get { return Base.type; } }
    
    // Returns the object for the position at index.
    func ElementAt(_ index: Int) throws -> WorkingBufferType
    {
        if (index < Count)
        {
            var buf = Base.Buffer; // work around Swift's silly restrictions.
            return Cast(buffer_get(&buf, GUInt(index)));
        }
           
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    
    // Copies the object into the end of the buffer.
    mutating func Add(_ obj: inout WorkingBufferType) throws -> Int
    {
        GuaranteeUnique();
        
        let index = Int(buffer_add(&Base.Buffer, &obj));
        if(index == -1)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
        
        UpdateBox();
        return index;
    }
     
    // Makes space for the element at index (by pushing existing elements further back), then copies the object into the position at index.
    mutating func Insert(_ index: Int, _ obj: inout WorkingBufferType) throws
    {
        if (index >= Count)
        {
            throw ContiguousMutableBufferError.OutOfRange;
        }
        
        GuaranteeUnique();
        if(buffer_insert(&Base.Buffer, &obj, GUInt(index)) == -1)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
        UpdateBox();
    }
    
    // Removes the specified element from the buffer, and moves the leftover elements so there's no gaps.
    mutating func Remove(_ index: Int) throws
    {
        if (index < Count)
        {
            GuaranteeUnique();
            buffer_remove(&Base.Buffer, GUInt(index));
            UpdateBox();
            return;
        }
            
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    // Clears the buffer.
    mutating func Clear()
    {
        for i in 0..<Count
        {
            // self.ReleaseAtIndex(i);
        }
        
        GuaranteeUnique();
        buffer_remove_range(&Base.Buffer, 0, GUInt(Count - 1));
        UpdateBox();
    }
        
    // Makes space for an element at index, returns the pointer to that empty space.
    mutating func MakeSpace(_ index: Int) throws -> UnsafeMutableRawPointer?
    {
        if (index <= Count)
        {
            GuaranteeUnique();
            let returnPtr = buffer_makespace(&Base.Buffer, GUInt(index));
            UpdateBox();
            return returnPtr;
        }
            
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    // Sets whether the buffer should autoresize.
     mutating func SetShouldAutoResize(_ shouldAutoResize: Bool)
    {
        GuaranteeUnique();
        buffer_set_shouldautoresize(&Base.Buffer, shouldAutoResize);
        UpdateBox();
    }
    
    // Sets the autoresize amount for the buffer, e.g, by how much should its capacity increase. The default (0) is its capacity will double.
    mutating func SetAutoResizeAmount(_ autoResizeAmount: UInt)
    {
        GuaranteeUnique();
        buffer_set_autogrow_amount(&Base.Buffer, GUInt(autoResizeAmount));
        UpdateBox();
    }
    
    // Manually deallocs the buffer. This buffer won't work anymore afterwards.
    mutating func DeallocBuffer()
    {
        if(GetBox().IsUnique())
        {
            buffer_free(&Base.Buffer);
        }
    }
}

struct Buffer<T>: GBufferProtocol
{
    typealias TheBoxable = Buffer<T>;
    typealias WorkingBufferType = T;
    var Core: BufferCore;
    
    var Base: BufferCore { get { return Core; } set { Core = newValue; } }
    var BoxContainer: Box<Buffer<T>>? = nil;

    
    // Inits this buffer.
    init(withInitialCapacity: Int = Int(GSETTINGS_CONSTANTS_DEFAULTBUFFERCAPACITY), withType: Any.Type = T.self) throws
    {
        Core = try BufferCore(withInitialCapacity: withInitialCapacity, withType: withType);
        BoxContainer = Box<Buffer<T>>(self);
    }
    
    // Inits this buffer with a copy of the supplied buffer. Events are copied as-is.
    init(withCopyOf: inout Buffer<T>, withExtraCapacityCount: Int = 0) throws
    {
        Core = try BufferCore(withCopyOf: &withCopyOf.Core);
        BoxContainer = Box<Buffer<T>>(self);
    }
    
    // Boxable.
    mutating func IsUnique() -> Bool
    {
        return BoxContainer!.IsUnique();
    }
    
    mutating func ReturnCopy() -> Buffer<T>
    {
        return try! Buffer<T>(withCopyOf: &self);
    }
    
    mutating func UpdateData(data: Buffer<T>)
    {
        Core = data.Core;
        BoxContainer = data.BoxContainer;
    }
    
    func GetBox() -> Box<Buffer<T>>
    {
        return BoxContainer!;
    }
    
    mutating func GuaranteeUnique()
    {
        BoxContainer!.GuaranteeUnique(&self);
    }
    
    mutating func UpdateBox()
    {
        BoxContainer!.Update(&self);
    }
    
    mutating func Dealloc()
    {
        buffer_free(&Core.Buffer);

    }
}


// Mutable by default.
// TODO: need to implement copy on write for this, as well as for the Events, like Swift arrays. 
public struct RawBuffer: GBufferProtocol
{
    typealias TheBoxable = RawBuffer;
    typealias WorkingBufferType = UnsafeMutableRawPointer?;
    var Core: BufferCore;
    
    var Base: BufferCore { get { return Core; } set { Core = newValue; } }
    var BoxContainer: Box<RawBuffer>? = nil;

    
    // Inits this buffer.
    init(withInitialCapacity: Int, withType: Any.Type) throws
    {
        Core = try BufferCore(withInitialCapacity: withInitialCapacity, withType: withType);
        BoxContainer = Box<RawBuffer>(self);

    }
    
    // Inits this buffer with a copy of the supplied buffer. Events are copied as-is.
    init(withCopyOf: inout RawBuffer, withExtraCapacityCount: Int = 0) throws
    {
        Core = try BufferCore(withCopyOf: &withCopyOf.Core);
        BoxContainer = Box<RawBuffer>(self);
    }
    
    // Boxable.
    mutating func IsUnique() -> Bool
    {
        return BoxContainer!.IsUnique();
    }
    
    mutating func ReturnCopy() -> RawBuffer
    {
        return try! RawBuffer(withCopyOf: &self);
    }
    
    mutating func UpdateData(data: RawBuffer)
    {
        Core = data.Core;
        BoxContainer = data.BoxContainer;
    }
    
    func GetBox() -> Box<RawBuffer>
    {
        return BoxContainer!;
    }
    
    mutating func GuaranteeUnique()
    {
        BoxContainer!.GuaranteeUnique(&self);
    }
    
    mutating func UpdateBox()
    {
        BoxContainer!.Update(&self);
    }
    
    mutating func Dealloc()
    {
        buffer_free(&Core.Buffer);

    }
}

private func OnBufferResized(_ target: UnsafeMutableRawPointer?)
{
    let swiftBuff: UnsafeMutablePointer<BufferCore> = Cast(target);
    swiftBuff.pointee.BufferResized();
}

private func OnBufferElementsMoved(_ target: UnsafeMutableRawPointer?)
{
    let swiftBuff: UnsafeMutablePointer<BufferCore> = Cast(target);
    swiftBuff.pointee.BufferElementsMoved();
}

public enum ContiguousMutableBufferError: Error
{
    case OutOfRange;
    case AllocError;
}
