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
// Boxes are used to implement copy-on-write semantics for Galah's value type collections.

internal protocol Boxable
{
    associatedtype TheBoxable: Boxable;
    mutating func ReturnCopy() -> TheBoxable;
    mutating func UpdateData(data: TheBoxable);
    func GetBox() -> Box<TheBoxable>;
    mutating func GuaranteeUnique();
    mutating func UpdateBox();
    mutating func Dealloc();
}

internal class Box<T> where T: Boxable
{
    private var value: T;
    private var semaphore: Semaphore;
    
    init(_ val: T)
    {
        value = val;
        semaphore = Semaphore();
    }
    
    deinit
    {
        value.Dealloc();
    }
    
    // Checks to see if this box is uniquely referenced. Thread safe.
    public func IsUnique() -> Bool
    {
        semaphore.Enter(max: 1);
        var theSelf = self;
        let isUnique = isKnownUniquelyReferenced(&theSelf);
        semaphore.Exit();

        if( !isUnique )
        {
            return false;
        }
        
        return true;
    }
    
    public func GuaranteeUnique(_ toCheck: inout T)
    {
        if(!IsUnique() && toCheck.GetBox() === self)
        {
            // Don't update this box because some stale struct somewhere is holding it.
            // Create new data instead.
            let newValue = value.ReturnCopy() as! T;
            toCheck.UpdateData(data: newValue as! T.TheBoxable);
        }
    }
    
    // Updates the passed toUpdate value, without checking for uniqueness (always check for uniqueness first or you may lose data!
    public func Update(_ toUpdate: inout T)
    {
        value = toUpdate;
    }
}

internal protocol DeallocListener
{
    func Dealloc();
}

// A more simple box that just keeps a dumb copy of its parent. The idea here is to run code on final dealloc.
// If you need the internal boxed copy to not be 'dumb' then be sure to update this whenever something changes. 
internal class DeallocBox<T> where T: DeallocListener
{
    var value: T;
    private var semaphore: Semaphore;
    
    init(_ val: T)
    {
        value = val;
        semaphore = Semaphore();
    }
    
    deinit
    {
        value.Dealloc();
    }
    
    // Checks to see if this box is uniquely referenced. Thread safe.
    public func IsUnique(_ toCheck: inout T) -> Bool
    {
        semaphore.Enter(max: 1);
        var theSelf = self;
        let isUnique = isKnownUniquelyReferenced(&theSelf);
        semaphore.Exit();
        
        return isUnique;
    }
}

