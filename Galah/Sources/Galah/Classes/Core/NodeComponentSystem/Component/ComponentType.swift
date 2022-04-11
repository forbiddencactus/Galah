//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2022, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// ComponentType is like HashableType but designed to make component types sortable.

typealias ComponentTypeID = UInt;

struct ComponentType : HashableType, Comparable
{
    let type: Component.Type;
    let typeID: ComponentTypeID;

    init(_ type: Component.Type)
    {
        self.type = type;
        typeID = Director.sharedInstance.componentTypeBank.GetIndex(type: self.type);
    }
    
    static func < (lhs: ComponentType, rhs: ComponentType) -> Bool
    {
        return lhs.typeID < rhs.typeID;
    }
    
    static func == (lhs: ComponentType, rhs: ComponentType) -> Bool
    {
        return lhs.typeID == rhs.typeID
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(typeID);
    }
}

struct ComponentTypeBank
{
    var componentTypeCounter: UInt = 0;
    var componentTypeIndices = ContiguousDictionary<HashedType,UInt>();
    
    // Gets the existing index for the type or creates a new one.
    public mutating func GetIndex(type: Component.Type) -> ComponentTypeID
    {
        let hashedType = HashedType(type);
        var returnVal = componentTypeIndices[hashedType];
        
        if(returnVal != nil)
        {
            return returnVal!;
        }
        
        returnVal = componentTypeCounter;
        componentTypeIndices[hashedType] = returnVal;
        componentTypeCounter += 1;
        
        return returnVal!;
        
    }
}
