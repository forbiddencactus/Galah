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

public class RawMutableBuffer
{
    fileprivate let type: Any.Type;
    fileprivate var buffer: GBuffer;
    public var Count: Int { get { return Int(buffer.count); } }
    public var Capacity: UInt { get { return UInt(buffer.capacity); } };
    
    public init(withInitialCapacity: Int, withType: Any.Type) throws
    {
        type = withType;
        let sizeOf: Int = SizeOf(withType);
        buffer = buffer_create(sizeOf, GUInt(withInitialCapacity), true);
        
        if(buffer.buffer == nil)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
                
        let callback : GBufferResizeCallback? =
        { (target : UnsafeMutableRawPointer?) -> () in
                
            let swiftBuff: RawMutableBuffer = Cast(target);
            swiftBuff.BufferResized();
        }
        
        buffer_addresizecallback(&buffer, callback, Cast(self));
    }
    
    public func GetType() -> Any.Type
    {
        return type;
    }
    
    public func PtrAt(_ index: Int) throws -> Ptr<VoidPtr>
    {
        if (index < Count)
        {
            return Ptr<VoidPtr>(buffer_get(&buffer, GUInt(index)));
        }
           
        throw ContiguousMutableBufferError.OutOfRange;
    }
       
    public func AddPtr(_ ptr: Ptr<VoidPtr>) throws -> Int
    {
        if(buffer_add(&buffer, ptr.raw) == -1)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
        
        return Count - 1;
    }
       
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
    
    public func Remove(_ index: Int) throws
    {
        if (index < Count)
        {
            buffer_remove(&buffer, GUInt(index));
            return;
        }
            
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    public func Clear()
    {
        buffer_remove_range(&buffer, 0, GUInt(Count - 1));
    }
        
    public func MakeSpace(_ index: Int) throws -> Ptr<VoidPtr>
    {
        if (index <= Count)
        {
            let returnPtr = Ptr<VoidPtr>(buffer_makespace(&buffer, GUInt(index))!);
            return returnPtr;
        }
            
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    internal func BufferResized() { }
    
    deinit
    {
        buffer_free(&buffer);
    }
}

public class MutableBuffer<T>: RawMutableBuffer, Sequence
{
    public init(withInitialCapacity: Int, withType: T.Type = T.self) throws
    {
        try super.init(withInitialCapacity: withInitialCapacity, withType: withType);
    }
        
    public func ItemAt(_ index: Int) throws -> T?
    {
        return try GetRefFromPointer(super.PtrAt(index));
    }
       
    public func Add(_ element: inout T) throws -> Int
    {
        return try super.AddPtr(Ptr<VoidPtr>(&element));
    }
       
    public func Insert(_ index: Int, _ element: inout T) throws
    {
        try super.InsertPtr(index, Ptr<VoidPtr>(&element));
    }
       
    // Sequence protocol:
    public func makeIterator() -> MutableBufferIterator<T>
    {
        return MutableBufferIterator(buffer: self, elementIndex: 0);
    }
}

public class RefMutableBuffer<T>: RawMutableBuffer, Sequence where T: GObject
{
    public init(withInitialCapacity: Int, withType: T.Type = T.self) throws
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
    public func makeIterator() -> RefMutableBufferIterator<T>
    {
        return RefMutableBufferIterator(buffer: self, elementIndex: 0);
    }
}

public struct MutableBufferIterator<T>: IteratorProtocol
{
    let buffer: MutableBuffer<T>;
    var elementIndex: Int;
    
    public init(buffer: MutableBuffer<T>, elementIndex: Int)
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

public struct RefMutableBufferIterator<T>: IteratorProtocol where T: GObject
{
    let buffer: RefMutableBuffer<T>;
    var elementIndex: Int;
    
    public init(buffer: RefMutableBuffer<T>, elementIndex: Int)
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
