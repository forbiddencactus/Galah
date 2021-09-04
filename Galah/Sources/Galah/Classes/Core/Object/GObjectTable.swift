//---- Galah Engine---------------------------------------------------------//
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

internal typealias GIndex = UInt32;

// GObjects are in charge of updating the table.
// However, if you're copying a GObject, you gotta give the object a hint through
// its WillCopy() and IsCopied() methods.
internal class GObjectTable
{
    public static let sharedInstance: GObjectTable = GObjectTable();
    
    private var
    objectIndex: GIndex = 0;
    
    private var
    lookupTable = Dictionary<GIndex, GObject>();
    
    // Gets an object from the lookup table.
    func GetObject(_ index: GIndex) -> GObject?
    {
        return lookupTable[index];
    }
    
    // Updates or adds an object in the lookup table.
    func UpdateObject(index: GIndex, reference: GObject)
    {
        lookupTable[index] = reference;
    }
    
    // Removes an object from the lookup table.
    func RemoveObject(_ index: GIndex)
    {
        lookupTable.removeValue(forKey: index);
    }
    
    // Returns a unique object index for a new object.
    internal func GetNewGIndex() -> GIndex
    {
        /*
        Note that if for some reason you exceed the index's max number,
        Galah will attempt to recycle an old unused index.
        */
        if(objectIndex < GIndex.max)
        {
            let returnVal = objectIndex;
            objectIndex += 1;
            return returnVal;
        }
        else
        {
            // If your program is getting to this point, you're probably doing things wrong.
            var possibleIndex: GIndex = 0;
            while true
            {
                if(possibleIndex >= GIndex.max)
                {
                    /*
                    Uh, you have too many objects?
                    Try increasing the size of GIndex.
                    Failing that, uh, don't allocate as many GObjects? xD
                    */
                    fatalError();
                }
                
                if(lookupTable[possibleIndex] == nil)
                {
                    return possibleIndex;
                }
                
                possibleIndex += 1;
            }
        }
    }
}
