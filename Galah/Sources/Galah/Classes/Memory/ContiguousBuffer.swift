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


//A contiguous buffer allocated on the heap containing elements of a particular type.
internal class ContiguousMutableBuffer<T> where T: BufferElement
{
    private let blueprint: T = T();
    private var buffer: UnsafeMutablePointer<T?>;
    
    private let initialCapacity: Int;
    private var capacity: Int;
    private var count: Int = 0;
    
    public init(withInitialCapacity: Int)
    {
        //Set the initial capacity
        initialCapacity = withInitialCapacity;
        capacity = initialCapacity;
        
        // populate the buffer, fill with nil
        buffer = UnsafeMutablePointer<T?>.allocate(capacity: initialCapacity);
        buffer.initialize(repeating: nil, count: initialCapacity);
    }
    
    public func ItemAt(_ index: Int) throws -> T
    {
        if (index < count)
        {
            return buffer[index]!;
        }
        
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    public func AddNew()
    {
        self.Add(blueprint);
    }
    
    public func Add(_ element: T)
    {
        if (count < capacity)
        {
        let p: UnsafeMutablePointer<T?> = buffer.advanced(by: count);
        p.initialize(to: element);
        
        count += 1;
        }
        else
        {
            //Resize.
            self.Resize();
            self.Add(element);
        }
    }
    
    public func InsertNew(_ index: Int) throws
    {
        do
        {
        try self.Insert(index, blueprint);
        }
        catch ContiguousMutableBufferError.OutOfRange
        {
        throw ContiguousMutableBufferError.OutOfRange;
        }
        
    }
    
    public func Insert(_ index: Int, _ element: T) throws
    {
        if (index < count)
        {
            let p: UnsafeMutablePointer<T?> = buffer.advanced(by: index);
            //p.deinitialize(count: 1); //Not needed?
            p.initialize(to: element);
        }
        
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    public func Delete(_ index: Int) throws
    {
        if (index < count)
        {
            if (index == (count - 1) )
            {
                buffer[index] = nil;
                count -= 1;
            }
            else
            {
                //WARNING: Not entirely sure if this will blow up the memory. Unit tests?
                let p: UnsafeMutablePointer<T?> = buffer.advanced(by: index);
                    
                p.assign(from: buffer.advanced(by: index + 1),count: count - index );
                buffer[count - 1] = nil;
                count -= 1;
            }
        }
        
        throw ContiguousMutableBufferError.OutOfRange;
    }
    
    internal func Resize()
    {
        let newCapacity: Int = capacity * capacity;
        let oldBuffer: UnsafeMutablePointer<T?> = buffer;
        buffer = UnsafeMutablePointer<T?>.allocate(capacity: newCapacity);
        
        buffer.assign(from: oldBuffer, count: capacity);
        capacity = newCapacity;
        
        oldBuffer.deallocate();
        
        /*let test: (ContiguousMutableBuffer<BufferElement>) ->() ->() = ContiguousMutableBuffer<BufferElement>.AddNew;
        
        let hullo: ContiguousMutableBuffer<BufferElement> = ContiguousMutableBuffer<BufferElement>(withInitialCapacity: 5);
        
        test(hullo)();*/
        
        
        //ARC will deallocate old buffer ref here? ¯\_(ツ)_/¯
    }
    
    deinit
    {
        buffer.deallocate();
    }
}

internal enum ContiguousMutableBufferError: Error
{
    case OutOfRange;
}
