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

// An object which is manually managed by the Galah engine.
open class GObject
{
    private static var internallyConstructed: Bool = false;
    
    // Default object constructor.
    public func OnDefaultConstruct() {}
    
    // Called whenever Galah constructs an instance from the default object.
    public func OnConstruct() {}
    
    // Called whenever Galah destroys an instance.
    public func OnDestroy() {}
    
    // Called whenever Galah 
    
    //Due to the way these objects are allocated/init, it's a bad idea to put any constructor behaviour here.
    public required init() throws
    {
        if(GObject.internallyConstructed != true)
        {
            throw GObjectError.NotProperlyConstructed;
            return;
        }
        GObject.internallyConstructed = false;
    };
    
    private static func ConstructDefault<T>() -> T? where T: GObject
    {
        internallyConstructed = true;
        let constr: T;
        do
        {
            constr = try T();
        }
        catch{}
        
        constr.OnConstruct();
        
        return constr;
    }
    
    internal static func Construct<T>(_ store: GObjectStore? = nil) -> T? where T: GObject
    {
        if(store != nil)
        {
            if(store?.defaultObjectPtr == nil)
            {
                return ConstructDefault();
            }
            
        }
        
        return nil;
    }
}

public enum GObjectError: Error
{
    // GObjects are manually managed by the engine. Don't use init!
    case NotProperlyConstructed;
    case AllocError;
}
