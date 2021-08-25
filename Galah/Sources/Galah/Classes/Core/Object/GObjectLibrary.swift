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

// These are all just workarounds because there's no easy way to do placement new in Swift.
// So we have to do dirty tricks. *shrug*
// Todo: figure out how to get placement new (probs some runtime hackery needed?)

import GalahNative.Memory;

struct GObjectStoreRaw
{
    internal var defaultObjectPtr: GObject? = nil;
    internal var mallocSize: MemSize = 0;
    
    public init(){}
    internal init(defaultObjectPtr: GObject?, mallocSize: MemSize)
    {
        self.defaultObjectPtr = defaultObjectPtr;
        self.mallocSize = mallocSize
    }
}

struct GObjectStore<T> where T: GObject
{
    internal var defaultObjectPtr: T? = nil;
    internal var mallocSize: MemSize = 0;
    
    // This looks slow. Todo: improve. Generics on Swift suuuucks :/
    public static func New() -> GObjectStore<T>
    {
        var raw = GObjectStoreRaw();
        let defaultObject: T = GObject.ConstructDefault(&raw)!;
        var omgSwiftSyntaxSucks: Any = defaultObject as Any;
        raw.mallocSize = SizeOf(&omgSwiftSyntaxSucks);
        let retVal = GObjectStore<T>(raw);
        return retVal;
    }
    
    public static func New() -> GObjectStoreRaw
    {
        var raw = GObjectStoreRaw();
        let defaultObject: T = GObject.ConstructDefault(&raw)!;
        var omgSwiftSyntaxSucks: Any = defaultObject as Any;
        raw.mallocSize = SizeOf(&omgSwiftSyntaxSucks);
        return raw;
    }
    
    public init(_ gObjStore: GObjectStoreRaw)
    {
        if(gObjStore.defaultObjectPtr is T)
        {
            defaultObjectPtr = (gObjStore.defaultObjectPtr as! T);
            mallocSize = gObjStore.mallocSize;
        }
    }
    
    public func GetRaw() -> GObjectStoreRaw
    {
        return GObjectStoreRaw(defaultObjectPtr: defaultObjectPtr, mallocSize: mallocSize);
    }
    
    private init() {}
}

// This whole thing is really cache unfriendly, todo rewrite properly. 
public class GObjectLib
{
    public static let sharedInstance = GObjectLib()
    private var internalDic: Dictionary<HashableType<GObject>, GObjectStoreRaw>;
    
    internal init()
    {
        internalDic = Dictionary<HashableType<GObject>, GObjectStoreRaw>();
    }
    
    public func GetDefaultObject<T>() -> T? where T: GObject
    {
        var val: GObjectStoreRaw? = internalDic[T.self];
        if(val == nil)
        {
            val = GObjectStore<T>.New();
            internalDic[T.self] = val;
        }
        
        if(val?.defaultObjectPtr != nil)
        {
            return val?.defaultObjectPtr as! T?;
        }
        else
        {
            return nil; //This shouldn't happen?
        }
    }
}

//Swiped from: https://stackoverflow.com/questions/42459484/make-a-swift-dictionary-where-the-key-is-type

/// Hashable wrapper for a metatype value.
struct HashableType<T> : Hashable
{

  static func == (lhs: HashableType, rhs: HashableType) -> Bool {
    return lhs.base == rhs.base
  }

  let base: T.Type

  init(_ base: T.Type) {
    self.base = base
  }
    
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(base))
  }
}

extension Dictionary {
  subscript<T>(key: T.Type) -> Value? where Key == HashableType<T> {
    get { return self[HashableType(key)] }
    set { self[HashableType(key)] = newValue }
  }
}
