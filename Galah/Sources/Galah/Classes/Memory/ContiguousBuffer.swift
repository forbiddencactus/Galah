/*
MIT License

Copyright © 2020, 2021 Alexis Griffin.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import GalahNative.Memory;

//A contiguous buffer allocated on the heap containing elements of a particular type.
public class ContiguousMutableBuffer<T> where T: GObject
{
    
    private var buffer: NativeBuffer;
    
    private var count: Int = 0;
    
    public var Capacity: GUInt { get { return buffer.capacity; } };
    
    
    public init(withInitialCapacity: Int) throws
    {
        let sizeOf: Int = GetSize<T>.SizeOf();
        buffer = buffer_create(sizeOf, uint(withInitialCapacity), true);

        if(buffer.buffer == nil)
        {
            throw ContiguousMutableBufferError.AllocError;
        }
    }
    
    public func ItemAt(_ index: Int) throws -> T?
    {
        if (index < count)
        {
            let ret: T? = GetRefFromPointer(buffer_get(&buffer, uint(index)));
            return ret;
        }
        
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    public func AddNew() throws
    {
        try self.Add(blueprint);
    }
    
    public func Add(_ element: T) throws
    {
        let ptr = GetPointerFromObject(element);
        
        if(buffer_add(&buffer, ptr) != -1)
        {
            count += 1;
            return;
        }
        
        throw ContiguousMutableBufferError.AllocError;
    }
    
    public func InsertNew(_ index: Int) throws
    {
        try self.Insert(index, blueprint);
    }
    
    public func Insert(_ index: Int, _ element: T) throws
    {
        if (index < count)
        {
            let ptr = GetPointerFromObject(element);
            if(buffer_insert(&buffer, ptr, uint(index)) != -1)
            {
                count += 1;
                return;
            }
            throw ContiguousMutableBufferError.AllocError;
        }
        
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    public func Remove(_ index: Int) throws
    {
        if (index < count)
        {
            buffer_remove(&buffer, uint(index));
            return;
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
