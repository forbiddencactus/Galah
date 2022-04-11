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
// A contiguous mutable dictionary allocated on the heap containing elements of a particular type.

import GalahNative.Settings;

fileprivate struct Bucket
{
    fileprivate var indices: Array<UInt>;
    
    fileprivate init()
    {
        indices = Array<UInt>();
    }
}

internal struct ContiguousDictionary<Key: Hashable, Value>
{
    // Split the buffers to achieve better cache efficiency.
    private var _keyBuffer: Buffer<Key>;
    private var _valueBuffer: Buffer<Value>;
    private var _bucketArray: Array<Bucket>;
    
    public var Count: Int { get { return Int(_keyBuffer.Count); } };
    public var Capacity: UInt { get { return UInt(_keyBuffer.Capacity); } };
    public var Mutable: Bool { get { return _keyBuffer.Mutable; } };
    
    subscript(key: Key) -> Value?
    {
        get
        {
            return GetValue(key);
        }
        set(newValue)
        {
            let ptr: UnsafeMutablePointer<Value> = unsafeBitCast(newValue, to: UnsafeMutablePointer<Value>.self);
            AddKey(key, &ptr.pointee);
        }
    }
    
    public init(withIntialCapacity: Int = Int(GSETTINGS_CONSTANTS_DEFAULTBUFFERCAPACITY))
    {
        _keyBuffer = try! Buffer<Key>(withInitialCapacity: withIntialCapacity);
        _valueBuffer = try! Buffer<Value>(withInitialCapacity: withIntialCapacity);
        _bucketArray = Array<Bucket>(repeating:Bucket(), count: Int(_keyBuffer.Capacity));
        
        // Unsafe trickery to go around Swift's annoying safety rules. 
        let ptrSelf: UnsafeMutablePointer<ContiguousDictionary<Key,Value>> = Cast(&self);
        let theCallback: (inout Buffer<Key>) ->() = { ptrSelf.pointee.KeyBufferDidResize(&$0);};
        ptrSelf.pointee._keyBuffer.BufferResizedEvent.Subscribe(&self, theCallback);
    }
    
    // Adds a new key with its associated key value pair. If the key already exists, it sets the new value.
    public mutating func AddKey(_ key: Key, _ value: inout Value)
    {
        let keyIndex = self.GetIndexForKey(key)
        if(keyIndex == -1)
        {
            let keyIndex: UInt = try!_keyBuffer.Add(&unsafeBitCast(key, to: UnsafeMutablePointer<Key>.self).pointee);
            try! _ = _valueBuffer.Add(&value);
            
            let bucketIndex: UInt = GetBucketIndex(key);
            
            _bucketArray[Int(bucketIndex)].indices.append(keyIndex);
        }
        else
        {
            try! _valueBuffer.Replace(keyIndex, &value);
        }
    }
    
    public func GetKey(_ index: UInt) -> Key?
    {
        if (index < _keyBuffer.Count)
        {
            return try! _keyBuffer.ElementAt(index);
        }
        
        return nil;
    }
    
    public func GetValue(_ key: Key) -> Value?
    {
        let index = GetIndexForKey(key);
        
        if (index != -1)
        {
            return try! _valueBuffer.ElementAt(UInt(index));
        }
        
        return nil;
    }
    
    public func GetValuePtr(_ key: Key) -> Ptr<Value>?
    {
        let index = GetIndexForKey(key);
        
        if (index != -1)
        {
            return try! _valueBuffer.PtrAt(UInt(index));
        }
        
        return nil;
    }
    
    public mutating func RemoveKey(_ key: Key)
    {
        let index = GetIndexForKey(key);
        try! _keyBuffer.Remove(UInt(index));
        try! _valueBuffer.Remove(UInt(index));
        
        self.RefreshBuckets();
    }
    
    public func GetKeyExists(_ key: Key) -> Bool
    {
        return GetIndexForKey(key) != -1;
    }
    
    private func GetBucketIndex(_ key: Key) -> UInt
    {
        return UInt(abs(key.hashValue % Int(_keyBuffer.Capacity)));
    }
    
    // TODO: See how fast this is.
    public func GetIndexForKey(_ key: Key) -> Int
    {
        let bucketIndex: UInt = GetBucketIndex(key);

        for index in _bucketArray[Int(bucketIndex)].indices
        {
            let potentialKey = try! _keyBuffer.ElementAt(index);
            var found: Bool = false;

            if (potentialKey == key)
            {
                found = true;
            }

            if(found) { return Int(index); }
        }
        
        return -1;
    }
    
    // TODO: Make this faster.
    private mutating func RefreshBuckets()
    {
        _bucketArray = Array<Bucket>(repeating:Bucket(), count: Int(_keyBuffer.Capacity));

        var count: UInt = 0;
        for key in _keyBuffer
        {
            let bucketIndex: UInt = GetBucketIndex(key);
            _bucketArray[Int(bucketIndex)].indices.append(count);
            count += 1;
        }
    }
    
    private mutating func KeyBufferDidResize(_ buffer: inout Buffer<Key>)
    {
        self.RefreshBuckets();
    }
}

