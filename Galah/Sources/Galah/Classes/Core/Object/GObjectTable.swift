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
// The table through which Handles keep track of where in memory GObjects live.

// Index for GObjects.
internal struct GIndex
{
    internal let index: UInt8;
    internal var counter: UInt8;
    
    init()
    {
        index = UInt8.max;
        counter = UInt8.max;
    }
    
    internal init(index: UInt8, counter: UInt8)
    {
        self.index = index;
        self.counter = counter;
    }
}

// GObjects are in charge of updating the table.
// However, if you're copying a GObject, you gotta give the object a hint through
// its WillCopy() and IsCopied() methods.
internal class GObjectTable
{
    public static let sharedInstance: GObjectTable = GObjectTable();
    
    private var
    objectIndex: UInt8 = 0;
    
    private var
    lookupTable = Dictionary<UInt8, LookupItem>();
    
    private var
    reuseCache = Array<GIndex>();
    
    // Gets an object from the lookup table.
    func GetObject(_ index: GIndex) -> GObject?
    {
        let item: LookupItem? = lookupTable[index.index];
        
        if( item?.index.counter == index.counter)
        {
            return item?.object;
        }
    }
    
    // Updates or adds an object in the lookup table.
    func UpdateObject(index: GIndex, reference: GObject)
    {
        let item: LookupItem? = lookupTable[index.index];
        
        if( item?.index.counter == index.counter)
        {
            lookupTable[index.index]?.object = reference;
        }
    }
    
    // Removes an object from the lookup table.
    func RemoveObject(_ index: GIndex)
    {
        let item: LookupItem? = lookupTable[index.index];
        
        if(item == nil) { return; }
        
        var reuseIndex = index;
        
        if( item!.index.counter == index.counter)
        {
            lookupTable.removeValue(forKey: index.index);
        }
        
        reuseIndex.counter += 1;
        reuseCache.append(reuseIndex);
    }
    
    // Returns a unique object index for a new object.
    internal func GetNewGIndex() -> GIndex
    {
        if( reuseCache.count > 0 )
        {
            let index = reuseCache.last!;
            reuseCache.removeLast();
            return index;
        }
        else
        {
            if(objectIndex < UInt8.max)
            {
                let index = GIndex(index: objectIndex, counter: 0);
                objectIndex += 1;
                return index;
            }
            else
            {
                // Uh... you have WAY too many objects.
                fatalError();
                return GIndex();
            }
        }
        
    }
    
    private struct LookupItem
    {
        public let index: GIndex;
        public var object: GObject;
    }
}
