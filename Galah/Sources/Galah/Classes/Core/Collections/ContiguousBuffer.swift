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

import Swift;
import GalahNative.Memory;
import GalahNative.Settings;

// Mutable by default.
// TODO: need to implement copy on write for this, as well as for the Events, like Swift arrays. 
public struct RawBuffer
{
    fileprivate let type: Any.Type;
    fileprivate var buffer: GBuffer;
    
    // Buffers sometimes autogrow and therefore all the pointers pointing to the buffer will go bad. Hook up to this to get notified when that happens.
    public let AutoGrowEvent = Event<RawBuffer>();
    
    // When an element is removed or inserted, the elements around it may have to be reshuffled. Therefore all the pointers pointing to the buffer will go bad. Hook up to this to get notified when that happens.
    public let ElementsMovedEvent = Event<RawBuffer>();
    
    // The number of elements in the buffer.
    public var Count: Int { get { return Int(buffer.count); } };
    
    // The capacity of the buffer.
    public var Capacity: UInt { get { return UInt(buffer.capacity); } };
    
    // Whether the buffer full auto resize once it is at capacity.
    public var Mutable: Bool { get { return buffer.isAutoResize; } };
    
    // Inits this buffer.
    public init(withInitialCapacity: Int, withType: Any.Type) throws
    {
        type = withType;
        let sizeOf: Int = ExtentsOf(withType);
        buffer = buffer_create(sizeOf, GUInt(withInitialCapacity), true);
        
        if(buffer.buffer == nil)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
        
        //buffer_addresizecallback(&buffer, OnBufferResized, Cast(self));
        //buffer_addelementsmovedcallback(&buffer, OnBufferElementsMoved, Cast(self));
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
            var buf = buffer; // work around Swift's silly restrictions.
            return Ptr<VoidPtr>(buffer_get(&buf, GUInt(index)));
        }
           
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    // Makes space for the element at index (by pushing existing elements further back), then Memcopies the specified pointer, by the size of the type of the buffer, into the end of the buffer. Auto grows.
    public mutating func Add<T>(_ obj: __owned T) throws -> Int
    {
        var mutate = obj;
        return try self.Add(&mutate);
    }
    
    // Makes space for the element at index (by pushing existing elements further back), then Memcopies the specified pointer, by the size of the type of the buffer, into the end of the buffer. Auto grows.
    public mutating func Add(_ obj: UnsafeRawPointer) throws -> Int
    {
        if(buffer_add(&buffer, obj) == -1)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
        
        let index = Count - 1;
        RetainAtIndex(index);
        return index;
    }
    
    // Memcopies the specified pointer, by the size of the type of the buffer, into the end of the buffer. Auto grows. 
    public mutating func Add(_ ptr: Ptr<VoidPtr>) throws -> Int
    {
        if(buffer_add(&buffer, ptr.raw) == -1)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
        
        let index = Count - 1;
        RetainAtIndex(index);
        return index;
    }
     
    // Makes space for the element at index (by pushing existing elements further back), then Memcopies the specified pointer, by the size of the type of the buffer, into the end of the buffer. Auto grows.
    public mutating func Insert(_ index: Int, _ ptr: Ptr<VoidPtr>) throws
    {
        if (index >= Count)
        {
            throw ContiguousMutableBufferError.OutOfRange;
        }
        
        if(buffer_insert(&buffer, ptr.raw, GUInt(index)) == -1)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
        
        RetainAtIndex(index);
    }
    
    // Removes the specified element from the buffer, and moves the leftover elements so there's no gaps.
    public mutating func Remove(_ index: Int) throws
    {
        if (index < Count)
        {
            self.ReleaseAtIndex(index);
            buffer_remove(&buffer, GUInt(index));
            return;
        }
            
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    // Clears the buffer.
    public mutating func Clear()
    {
        for i in 0..<Count
        {
            self.ReleaseAtIndex(i);
        }
        buffer_remove_range(&buffer, 0, GUInt(Count - 1));
    }
        
    // Makes space for an element at index, returns the pointer to that empty space.
    public mutating func MakeSpace(_ index: Int) throws -> Ptr<VoidPtr>
    {
        if (index <= Count)
        {
            let returnPtr = Ptr<VoidPtr>(buffer_makespace(&buffer, GUInt(index))!);
            return returnPtr;
        }
            
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    // Sets whether the buffer should autoresize.
    public mutating func SetShouldAutoResize(_ shouldAutoResize: Bool)
    {
        buffer_set_shouldautoresize(&buffer, shouldAutoResize);
    }
    
    // Sets the autoresize amount for the buffer, e.g, by how much should its capacity increase. The default (0) is its capacity will double.
    public mutating func SetAutoResizeAmount(_ autoResizeAmount: UInt)
    {
        buffer_set_autogrow_amount(&buffer, GUInt(autoResizeAmount));
    }
    
    // Manually deallocs the buffer. This buffer won't work anymore afterwards.
    public mutating func DeallocBuffer()
    {
        buffer_free(&buffer);
    }
        
    // Callback for when the C buffer resizes. 
    internal func BufferResized()
    {
        AutoGrowEvent.Broadcast(self);
    }
    
    // Callback for when the C buffer moves elements around.
    internal func BufferElementsMoved()
    {
        ElementsMovedEvent.Broadcast(self);
    }
    
    private mutating func RetainAtIndex(_ index: Int)
    {
        if(type != AnyObject.self)
        {
            let ptr = buffer_get(&buffer, Cast(index));
            _ = Unmanaged<GObject>.fromOpaque(ptr!).retain();
        }

    }
    
    // Runs the destructor for any object we're about to stomp on / delete, so it can safely release any memory it's holding on to. 
    private mutating func ReleaseAtIndex(_ index: Int)
    {
        if(type == AnyObject.self)
        {
            let ptr = buffer_get(&buffer, Cast(index));
            Unmanaged<GObject>.fromOpaque(ptr!).release();
        }
        
        // TODO: structs! :D
    }
}

public struct Buffer<T>: Sequence
{
    private var internalBuffer: RawBuffer;
    
    // Buffers sometimes autogrow and therefore all the pointers pointing to the buffer will go bad. Hook up to this to get notified when that happens.
    public var AutoGrowEvent: Event<RawBuffer> { get { return internalBuffer.AutoGrowEvent; } }
    
    // When an element is removed or inserted, the elements around it may have to be reshuffled. Therefore all the pointers pointing to the buffer will go bad. Hook up to this to get notified when that happens.
    public var ElementsMovedEvent: Event<RawBuffer> { get { return internalBuffer.ElementsMovedEvent; } }
    
    // The number of elements in the buffer.
    public var Count: Int { get { return internalBuffer.Count; } };
    
    // The capacity of the buffer.
    public var Capacity: UInt { get { return internalBuffer.Capacity; } };
    
    // Whether the buffer full auto resize once it is at capacity.
    public var Mutable: Bool { get { return internalBuffer.Mutable; } };
    
    public init(withInitialCapacity: Int = Int(GSETTINGS_CONSTANTS_DEFAULTBUFFERCAPACITY), withType: T.Type = T.self) throws
    {
         internalBuffer = try RawBuffer.init(withInitialCapacity: withInitialCapacity, withType: withType);
    }
        
    public func ItemAt(_ index: Int) throws -> T?
    {
        return try GetRefFromPointer(internalBuffer.PtrAt(index));
    }
      
    @discardableResult
    public mutating func Add(_ element: T) throws -> Int
    {
        return try internalBuffer.Add(element);
    }
       
    public mutating func Insert(_ index: Int, _ element: inout T) throws
    {
        try internalBuffer.Insert(index, Ptr<VoidPtr>(&element));
    }
       
    // Sequence protocol:
    public func makeIterator() -> BufferIterator<T>
    {
        return BufferIterator(buffer: self, elementIndex: 0);
    }
}

public struct RefBuffer<T>: Sequence where T: GObject
{
    private var internalBuffer: RawBuffer;
    
    // Buffers sometimes autogrow and therefore all the pointers pointing to the buffer will go bad. Hook up to this to get notified when that happens.
    public var AutoGrowEvent: Event<RawBuffer> { get { return internalBuffer.AutoGrowEvent; } }
    
    // When an element is removed or inserted, the elements around it may have to be reshuffled. Therefore all the pointers pointing to the buffer will go bad. Hook up to this to get notified when that happens.
    public var ElementsMovedEvent: Event<RawBuffer> { get { return internalBuffer.ElementsMovedEvent; } }
    
    // The number of elements in the buffer.
    public var Count: Int { get { return internalBuffer.Count; } };
    
    // The capacity of the buffer.
    public var Capacity: UInt { get { return internalBuffer.Capacity; } };
    
    // Whether the buffer full auto resize once it is at capacity.
    public var Mutable: Bool { get { return internalBuffer.Mutable; } };

    public init(withInitialCapacity: Int = Int(GSETTINGS_CONSTANTS_DEFAULTBUFFERCAPACITY), withType: T.Type = T.self) throws
    {
        internalBuffer = try RawBuffer.init(withInitialCapacity: withInitialCapacity, withType: withType);
    }
        
    public func ItemAt(_ index: Int) throws -> Ref<T>
    {
        return try Ref<T>(internalBuffer.PtrAt(index));
    }
       
    public mutating func Add(_ element: inout Ref<T>) throws -> Int
    {
        return try internalBuffer.Add(element._ref);
    }
       
    public mutating func Insert(_ index: Int, _ element: inout Ref<T>) throws
    {
        try internalBuffer.Insert(index, Ptr<VoidPtr>(&element._ref));
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

private func OnBufferResized(_ target: UnsafeMutableRawPointer?)
{
    let swiftBuff: RawBuffer = Cast(target);
    swiftBuff.BufferResized();
}

private func OnBufferElementsMoved(_ target: UnsafeMutableRawPointer?)
{
    let swiftBuff: RawBuffer = Cast(target);
    swiftBuff.BufferElementsMoved();
}
