//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020, 2021, the Galah contributors.
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


import GalahNative.Memory;
import GalahNative.Settings;

// Mutable by default.
public class RawBuffer
{
    fileprivate let type: Any.Type;
    fileprivate var buffer: GBuffer;
    
    public let AutoGrowEvent = Event<RawBuffer>();
    public var Count: Int { get { return Int(buffer.count); } };
    public var Capacity: UInt { get { return UInt(buffer.capacity); } };
    public var Mutable: Bool { get { return buffer.isAutoResize; } };
    
    public init(withInitialCapacity: Int, withType: Any.Type) throws
    {
        type = withType;
        let sizeOf: Int = ExtentsOf(withType);
        buffer = buffer_create(sizeOf, GUInt(withInitialCapacity), true);
        
        if(buffer.buffer == nil)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
                
        let callback : GBufferResizeCallback? =
        { (target : UnsafeMutableRawPointer?) -> () in
                
            let swiftBuff: RawBuffer = Cast(target);
            swiftBuff.BufferResized();
        }
        
        buffer_addresizecallback(&buffer, callback, Cast(self));
    }
    
    // Returns the type that this buffer stores.
    public func GetType() -> Any.Type
    {
        return type;
    }
    
    // Returns the pointer for the position at index.
    public func PtrAt(_ index: Int) throws -> Ptr<VoidPtr>
    {
        if (index < Count)
        {
            return Ptr<VoidPtr>(buffer_get(&buffer, GUInt(index)));
        }
           
        throw ContiguousMutableBufferError.OutOfRange;
    }
       
    // Memcopies the specified pointer, by the size of the type of the buffer, into the end of the buffer. Auto grows. 
    public func AddPtr(_ ptr: Ptr<VoidPtr>) throws -> Int
    {
        if(buffer_add(&buffer, ptr.raw) == -1)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
        
        return Count - 1;
    }
     
    // Makes space for the element at index (by pushing existing elements further back), then Memcopies the specified pointer, by the size of the type of the buffer, into the end of the buffer. Auto grows.
    public func InsertPtr(_ index: Int, _ ptr: Ptr<VoidPtr>) throws
    {
        if (index >= Count)
        {
            throw ContiguousMutableBufferError.OutOfRange;
        }
        
        if(buffer_insert(&buffer, ptr.raw, GUInt(index)) == -1)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
    }
    
    // Removes the specified element from the buffer, and moves the leftover elements so there's no gaps.
    public func Remove(_ index: Int) throws
    {
        if (index < Count)
        {
            buffer_remove(&buffer, GUInt(index));
            return;
        }
            
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    // Clears the buffer.
    public func Clear()
    {
        buffer_remove_range(&buffer, 0, GUInt(Count - 1));
    }
        
    // Makes space for an element at index, returns the pointer to that empty space.
    public func MakeSpace(_ index: Int) throws -> Ptr<VoidPtr>
    {
        if (index <= Count)
        {
            let returnPtr = Ptr<VoidPtr>(buffer_makespace(&buffer, GUInt(index))!);
            return returnPtr;
        }
            
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    // Sets whether the buffer should autoresize.
    public func SetShouldAutoResize(_ shouldAutoResize: Bool)
    {
        buffer_set_shouldautoresize(&buffer, shouldAutoResize);
    }
    
    // Sets the autoresize amount for the buffer, e.g, by how much should its capacity increase. The default (0) is its capacity will double.
    public func SetAutoResizeAmount(_ autoResizeAmount: UInt)
    {
        buffer_set_autogrow_amount(&buffer, GUInt(autoResizeAmount));
    }
    
    // Manually deallocs the buffer. This buffer won't work anymore afterwards.
    public func DeallocBuffer()
    {
        buffer_free(&buffer);
    }
        
    internal func BufferResized()
    {
        AutoGrowEvent.Broadcast(self);
    }
    
    deinit
    {
        buffer_free(&buffer);
    }
}

public class Buffer<T>: RawBuffer, Sequence
{
    public init(withInitialCapacity: Int = Int(GSETTINGS_CONSTANTS_DEFAULTBUFFERCAPACITY), withType: T.Type = T.self) throws
    {
        try super.init(withInitialCapacity: withInitialCapacity, withType: withType);
    }
        
    public func ItemAt(_ index: Int) throws -> T?
    {
        return try GetRefFromPointer(super.PtrAt(index));
    }
      
    @discardableResult
    public func Add(_ element: inout T) throws -> Int
    {
        return try super.AddPtr(Ptr<VoidPtr>(&element));
    }
       
    public func Insert(_ index: Int, _ element: inout T) throws
    {
        try super.InsertPtr(index, Ptr<VoidPtr>(&element));
    }
       
    // Sequence protocol:
    public func makeIterator() -> BufferIterator<T>
    {
        return BufferIterator(buffer: self, elementIndex: 0);
    }
}

public class RefBuffer<T>: RawBuffer, Sequence where T: GObject
{
    public init(withInitialCapacity: Int = Int(GSETTINGS_CONSTANTS_DEFAULTBUFFERCAPACITY), withType: T.Type = T.self) throws
    {
        try super.init(withInitialCapacity: withInitialCapacity, withType: withType);
    }
        
    internal func ItemAt(_ index: Int) throws -> Ref<T>
    {
        return try Ref<T>(super.PtrAt(index));
    }
       
    internal func Add(_ element: inout Ref<T>) throws -> Int
    {
        return try super.AddPtr(Ptr<VoidPtr>(&element._ref));
    }
       
    internal func Insert(_ index: Int, _ element: inout Ref<T>) throws
    {
        try super.InsertPtr(index, Ptr<VoidPtr>(&element._ref));
    }
       
    // Sequence protocol:
    public func makeIterator() -> RefBufferIterator<T>
    {
        return RefBufferIterator(buffer: self, elementIndex: 0);
    }
}

public struct BufferIterator<T>: IteratorProtocol
{
    let buffer: Buffer<T>;
    var elementIndex: Int;
    
    public init(buffer: Buffer<T>, elementIndex: Int)
    {
        self.buffer = buffer;
        self.elementIndex = elementIndex;
    }
    
    public mutating func next() -> T?
    {
        if(elementIndex < buffer.Count)
        {
            do
            {
                let ret: T? = try buffer.ItemAt(elementIndex);
                elementIndex += 1;
                return ret;
            }
            catch
            {
                return nil;
            }
        }
        
        return nil;
    }
}

public struct RefBufferIterator<T>: IteratorProtocol where T: GObject
{
    let buffer: RefBuffer<T>;
    var elementIndex: Int;
    
    public init(buffer: RefBuffer<T>, elementIndex: Int)
    {
        self.buffer = buffer;
        self.elementIndex = elementIndex;
    }
    
    public mutating func next() -> Ref<T>?
    {
        if(elementIndex < buffer.Count)
        {
            do
            {
                let ret: Ref<T>? = try buffer.ItemAt(elementIndex);
                elementIndex += 1;
                return ret;
            }
            catch
            {
                return nil;
            }
        }
        
        return nil;
    }
}

public enum ContiguousMutableBufferError: Error
{
    case OutOfRange;
    case AllocError;
}
