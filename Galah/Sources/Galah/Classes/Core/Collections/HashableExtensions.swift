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


// Swiped from: https://stackoverflow.com/questions/42459484/make-a-swift-dictionary-where-the-key-is-type
// This particular chunk of code is licenced according to stack overflow's terms, CC-BY-SA 4.0.
// Hashable wrapper for a metatype value.

struct HashableType<T> : Hashable
{

  static func == (lhs: HashableType, rhs: HashableType) -> Bool {
    return lhs.base == rhs.base
  }

  let base: T.Type

  init(_ base: T.Type) {
    self.base = base
  }
    
  func hash(into hasher: inout Hasher)
  {
    hasher.combine(ObjectIdentifier(base))
  }
}

extension Dictionary
{
  subscript<T>(key: T.Type) -> Value? where Key == HashableType<T>
  {
    get { return self[HashableType(key)] }
    set { self[HashableType(key)] = newValue }
  }
}
