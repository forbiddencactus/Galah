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
// Extensions for Arrays. 

extension Array
{
    // Returns the index of the n occurence of element. occurence = 0 would return the index for the first found element in the array. Returns nil if none found.
    public func IndexForElementOccurence(element: Element, occurence: Int) -> Int? where Element: Equatable
    {
        let firstIndex = self.firstIndex(of: element);
        
        if(occurence == 0 || firstIndex == nil)
        {
            return firstIndex;
        }
        
        var occurenceCount = 0;
        for index in firstIndex!..<self.count
        {
            let theElement = self[index];
            if(element == theElement)
            {
                occurenceCount += 1;
                
                if(occurenceCount == occurence)
                {
                    return index;
                }
            }
        }
        
        return nil;
    }
}
