//---- Galah Engine---------------------------------------------------------//
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

public class ContiguousMutableBuffer<T> where T: GObject
{
    
    private var buffer: NativeBuffer;
    
    public var Count: Int { get { return Int(buffer.count); } }
    public var Capacity: UInt { get { return UInt(buffer.capacity); } };
    
    
    public init(withInitialCapacity: Int) throws
    {
        let sizeOf: Int = GetSize<T>.SizeOf();
        buffer = buffer_create(sizeOf, GUInt(withInitialCapacity), true);

        if(buffer.buffer == nil)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
    }
    
    public func ItemAt(_ index: Int) throws -> T?
    {
        if (index < Count)
        {
            let ret: T? = GetRefFromPointer(buffer_get(&buffer, GUInt(index)));
            return ret;
        }
        
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    public func AddNew() throws
    {
        let ptr = try MakeSpace(Count);
        
        T.Construct(ptr);
    }
    
    public func Add(_ element: T) throws
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
        T.Construct(ptr);
    }
    
    public func Insert(_ index: Int, _ element: T) throws
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
    
    public func MakeSpace(_ index: Int) throws -> Ptr<T>
    {
        if (index <= Count)
        {
            let returnPtr = Ptr<T>(buffer_makespace(&buffer, GUInt(index))!);
            return returnPtr;
        }
        
        throw ContiguousMutableBufferError.OutOfRange;
    }
    

        
        /*let test: (ContiguousMutableBuffer<BufferElement>) ->() ->() = ContiguousMutableBuffer<BufferElement>.AddNew;
        
        let hullo: ContiguousMutableBuffer<BufferElement> = ContiguousMutableBuffer<BufferElement>(withInitialCapacity: 5);
        
        test(hullo)();*/
        
        
        //ARC will deallocate old buffer ref here? ¯\_(ツ)_/¯
    
    
    deinit
    {
        buffer_free(&buffer);
    }
}

public enum ContiguousMutableBufferError: Error
{
    case OutOfRange;
    case AllocError;
}
