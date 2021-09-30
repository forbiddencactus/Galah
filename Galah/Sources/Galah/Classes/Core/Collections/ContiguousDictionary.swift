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
// A contiguous mutable dictionary allocated on the heap containing elements of a particular type.

import GalahNative.Settings;

fileprivate struct Bucket
{
    fileprivate var indices: Array<Int>;
    
    fileprivate init()
    {
        indices = Array<Int>();
    }
}

public class ContiguousDictionary<Key: Hashable, Value>
{
    // Split the buffers to achieve better cache efficiency.
    private var _keyBuffer: Buffer<Key>;
    private var _valueBuffer: Buffer<Value>;
    private var _bucketArray: Array<Bucket>;
    
    public var Count: Int { get { return Int(_keyBuffer.Count); } };
    public var Capacity: UInt { get { return UInt(_keyBuffer.Capacity); } };
    public var Mutable: Bool { get { return _keyBuffer.Mutable; } };
    
    public init(withIntialCapacity: Int = Int(GSETTINGS_CONSTANTS_DEFAULTBUFFERCAPACITY))
    {
        _keyBuffer = try! Buffer<Key>(withInitialCapacity: withIntialCapacity);
        _valueBuffer = try! Buffer<Value>(withInitialCapacity: withIntialCapacity);
        _bucketArray = Array<Bucket>(repeating:Bucket(), count: Int(_keyBuffer.Capacity));
        
        _keyBuffer.AutoGrowEvent.Subscribe(self, self.KeyBufferDidResize);
    }
    
    public func AddKey(_ key: inout Key, _ value: inout Value)
    {
        let keyIndex = self.GetIndexForKey(key)
        if(keyIndex == -1)
        {
            let keyIndex: Int = try!_keyBuffer.Add(&key);
            try! _valueBuffer.Add(&value);
            
            let bucketIndex: Int = GetBucketIndex(key);
            
            _bucketArray[bucketIndex].indices.append(keyIndex);
        }
    }
    
    public func RemoveKey(_ key: Key)
    {
        let index = GetIndexForKey(key);
        try! _keyBuffer.Remove(index);
        try! _valueBuffer.Remove(index);
        
        self.RefreshBuckets();
    }
    
    public func GetKeyExists(_ key: Key) -> Bool
    {
        return GetIndexForKey(key) != -1;
    }
    
    private func GetBucketIndex(_ key: Key) -> Int
    {
        return abs(key.hashValue % Int(_keyBuffer.Capacity))
    }
    
    // TODO: See how fast this is.
    public func GetIndexForKey(_ key: Key) -> Int
    {
        let bucketIndex: Int = GetBucketIndex(key);

        for index in _bucketArray[bucketIndex].indices
        {
            // Using pointers should avoid retain and copy hits.
            let potentialKey: Ptr<Key> = Cast(try! _keyBuffer.PtrAt(index));
            var found: Bool = false;

            potentialKey.RunFunc
            {
                if($0 == key)
                {
                    found = true;
                }
            }
            
            if(found) { return index; }
        }
        
        return -1;
    }
    
    // TODO: Make this faster.
    private func RefreshBuckets()
    {
        _bucketArray = Array<Bucket>(repeating:Bucket(), count: Int(_keyBuffer.Capacity));

        var count: Int = 0;
        for key in _keyBuffer
        {
            let bucketIndex: Int = GetBucketIndex(key);
            _bucketArray[bucketIndex].indices.append(count);
            count += 1;
        }
    }
    
    private func KeyBufferDidResize(_ buffer: RawBuffer)
    {
        self.RefreshBuckets();
    }
}
