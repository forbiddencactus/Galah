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

public class ContiguousMutableBuffer: Sequence
{
    private let type: GObject.Type;
    private var buffer: NativeBuffer;
    
    public var Count: Int { get { return Int(buffer.count); } }
    public var Capacity: UInt { get { return UInt(buffer.capacity); } };
    
    public init(withType: GObject.Type, withInitialCapacity: Int) throws
    {
        type = withType;
        let sizeOf: Int = SizeOf(withType);
        buffer = buffer_create(sizeOf, GUInt(withInitialCapacity), true);
        
        if(buffer.buffer == nil)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
    }
        
    public func GetType() -> GObject.Type
    {
        return type;
    }
    
    public func ItemAt(_ index: Int) throws -> GObject?
    {
        if (index < Count)
        {
            let ret: GObject? = GetRefFromPointer(buffer_get(&buffer, GUInt(index)));
            return ret;
        }
           
        throw ContiguousMutableBufferError.OutOfRange;
    }
       
    public func AddNew() throws
    {
        let ptr = try MakeSpace(Count);
           
        GObject.Construct(type: type, ptr: ptr);
    }
       
    public func Add(_ element: GObject) throws
    {
        let ptr = GetPointerFromObject(element);
           
        if(buffer_add(&buffer, ptr) == -1)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
    }
       
    public func InsertNew(_ index: Int) throws
    {
        let ptr = try MakeSpace(index);
        GObject.Construct(type: type, ptr: ptr);
    }
       
    public func Insert(_ index: Int, _ element: GObject) throws
    {
        if (index >= Count)
        {
            throw ContiguousMutableBufferError.OutOfRange;
        }
           
        let ptr = GetPointerFromObject(element);
        if(buffer_insert(&buffer, ptr, GUInt(index)) == -1)
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
       
    public func MakeSpace(_ index: Int) throws -> Ptr<VoidPtr>
    {
        if (index <= Count)
        {
            let returnPtr = Ptr<VoidPtr>(buffer_makespace(&buffer, GUInt(index))!);
            return returnPtr;
        }
           
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    // Sequence protocol:
    public func makeIterator() -> ContiguousMutableBufferIterator<GObject>
    {
        return ContiguousMutableBufferIterator(buffer: self, elementIndex: 0);
    }
    
    deinit
    {
        buffer_free(&buffer);
    }
}

public class ContiguousMutableBufferT<T>: ContiguousMutableBuffer where T: GObject
{
    public init(withInitialCapacity: Int) throws
    {
        try super.init(withType: T.self, withInitialCapacity: withInitialCapacity);
    }
    
    public func ItemAt(_ index: Int) throws -> T?
    {
        return try super.ItemAt(index) as! T?;
    }
    
    public func Add(_ element: T) throws
    {
        try super.Add(element);
    }
    
    public func Insert(_ index: Int, _ element: T) throws
    {
        try super.Insert(index, element);
    }
    
    public func MakeSpace(_ index: Int) throws -> Ptr<T>
    {
        return try Ptr<T>(super.MakeSpace(index));
    }
    
    // Sequence protocol:
    public func makeIteratorT() -> ContiguousMutableBufferIterator<T>
    {
        return ContiguousMutableBufferIterator<T>(buffer: self, elementIndex: 0);
    }
        
        /*let test: (ContiguousMutableBuffer<BufferElement>) ->() ->() = ContiguousMutableBuffer<BufferElement>.AddNew;
        
        let hullo: ContiguousMutableBuffer<BufferElement> = ContiguousMutableBuffer<BufferElement>(withInitialCapacity: 5);
        
        test(hullo)();*/
}

public struct ContiguousMutableBufferIterator<T>: IteratorProtocol where T: GObject
{
    let buffer: ContiguousMutableBuffer;
    var elementIndex: Int;
    
    public init(buffer: ContiguousMutableBuffer, elementIndex: Int)
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
                let ret: T? = try buffer.ItemAt(elementIndex) as! T?;
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
