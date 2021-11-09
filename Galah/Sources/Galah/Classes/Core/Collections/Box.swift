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
// Boxes are used to implement copy-on-write semantics for Galah's value type collections.

internal protocol Boxable
{
    associatedtype TheBoxable: Boxable;
    func ReturnCopy() -> TheBoxable;
    func UpdateData(data: TheBoxable);
    func GetBox() -> Box<TheBoxable>;
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
    
    // Checks to see if this box is uniquely referenced.
    public func IsUnique(_ toCheck: inout T) -> Bool
    {
        semaphore.Enter(max: 1);
        
        var theSelf = self;
        let isUnique = isKnownUniquelyReferenced(&theSelf);
        semaphore.Exit();

        if( !isUnique )
        {
            value = value.ReturnCopy() as! T;
            self.Update(&toCheck);
            return false;
        }
        
        return true;
    }
    
    // Updates the passed toUpdate value, without checking for uniqueness (always check for uniqueness first or you may lose data!
    public func Update(_ toUpdate: inout T)
    {
        toUpdate.UpdateData(data: toUpdate as! T.TheBoxable);
    }
}
