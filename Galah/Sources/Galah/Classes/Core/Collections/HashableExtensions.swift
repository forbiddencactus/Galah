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
// Extensions to make things hashable.

public struct HashableRef<T>: Hashable where T: AnyObject
{
    internal let ptr: UnsafeMutableRawPointer;
    
    public init(_ inRef: T)
    {
        ptr = Cast(inRef);
    }
    
    public static func ==(lhs: HashableRef, rhs: HashableRef) -> Bool
    {
        return lhs.ptr == rhs.ptr;
    }

    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(ptr);
    }
}

extension Dictionary
{
  subscript<T>(key: T) -> Value? where Key == HashableRef<T>
  {
    get { return self[HashableRef(key)] }
    set { self[HashableRef(key)] = newValue }
  }
}

protocol HashableType : Hashable
{
}

struct HashableTypeOf<T> : HashableType
{
    static func == (lhs: HashableTypeOf, rhs: HashableTypeOf) -> Bool
    {
        return lhs.type == rhs.type
    }
    
    let type: T.Type
    
    init(_ type: T.Type)
    {
        self.type = type;
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(ObjectIdentifier(type));
    }
}

struct HashedType : HashableType
{
    static func == (lhs: HashedType, rhs: HashedType) -> Bool
    {
        return lhs.type == rhs.type;
    }

    let type: Any.Type

    init(_ type: Any.Type)
    {
        self.type = type;
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(ObjectIdentifier(type));
    }
}

extension Dictionary
{
  subscript<T>(key: T.Type) -> Value? where Key == HashedType
  {
    get { return self[HashedType(key)] }
    set { self[HashedType(key)] = newValue }
  }
}
