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
// The Archetype map is used to find archetypes based on the component types or tags it contains. 

import GalahNative.Settings;

internal struct NodeArchetypeMap
{
    var archetypeTypes = Dictionary<ComponentType,Array<NodeArchetypeID>>();
    var archetypeTags = Dictionary<ArchetypeTagKeyValuePair, Array<NodeArchetypeID>>();
    var archetypeComposition = Dictionary<Array<ComponentType>, Array<NodeArchetypeID>>();
    var archetypeTagComposition = Dictionary<Array<ArchetypeTagKeyValuePair>, Array<NodeArchetypeID>>();
    
    // Archetype sort mode...
    var archetypeTagSortMode: NodeArchetypeTagSortMode = NodeArchetypeTagSortMode.MatchArchetypeToTags;
    var archetypeTagIncludeList = Dictionary<NodeArchetypeTag, Int>();
    var archetypeTagIgnoreList = Dictionary<NodeArchetypeTag, Int>();
    
    // Add a NodeArchetypeID for a particular node composition (input arrays must be sorted).
    mutating func AddArchetype(archetypeID: NodeArchetypeID, nodeComponentTypes: Array<ComponentType>, nodeArchetypeTags: Array<ArchetypeTagKeyValuePair>)
    {
        // Add the archetype composition...
        if(archetypeComposition[nodeComponentTypes] == nil)
        {
            archetypeComposition[nodeComponentTypes] = Array<NodeArchetypeID>();
        }
        archetypeComposition[nodeComponentTypes]!.append(archetypeID);
        
        // Add the individual archetype types...
        for componentType in nodeComponentTypes
        {
            if(archetypeTypes[componentType] == nil)
            {
                archetypeTypes[componentType] = Array<NodeArchetypeID>();
            }
            
            assert( !(archetypeTypes[componentType]!.contains(archetypeID)), "Archetype might already exist?");
            archetypeTypes[componentType]!.append(archetypeID);
        }
        
        // Now, filter the tags to those that concern us...
        var tagCopy = Array<ArchetypeTagKeyValuePair>();
        if(archetypeTagSortMode != NodeArchetypeTagSortMode.IgnoreArchetypeTags)
        {
            for tag in nodeArchetypeTags
            {
                if(self.ArchetypeTagIsInUse(archetypeTag: tag.key))
                {
                    tagCopy.append(tag);
                }
            }
        }
        
        // Add the filtered, sorted tag composition.
        tagCopy.sort();
        if(archetypeTagComposition[tagCopy] == nil)
        {
            archetypeTagComposition[tagCopy] = Array<NodeArchetypeID>();
        }
        archetypeTagComposition[tagCopy]!.append(archetypeID);
        
        // Add the individual tags.
        for tag in tagCopy
        {
            if(archetypeTags[tag] == nil)
            {
                archetypeTags[tag] = Array<NodeArchetypeID>();
            }
            
            assert( !(archetypeTags[tag]!.contains(archetypeID)), "Archetype might already exist?");
            archetypeTags[tag]!.append(archetypeID);
        }
    }

    
    // Get the NodeArchetypeID for a particular node composition (input arrays must be sorted).
    func GetArchetypeForNodeComposition(nodeComponentTypes: Array<ComponentType>, nodeArchetypeTags: Array<ArchetypeTagKeyValuePair>, potentialArchetypes: inout Array<NodeArchetypeID>) -> NodeArchetypeID?
    {
        var idealArchetype: NodeArchetypeID? = nil;
        potentialArchetypes.removeAll();
        
        let compositionMatches = archetypeComposition[nodeComponentTypes];
        if(compositionMatches != nil)
        {
            potentialArchetypes.append(contentsOf: compositionMatches!);
        }
        
        if(potentialArchetypes.isEmpty)
        {
            return idealArchetype;
        }
        
        if(archetypeTagSortMode == NodeArchetypeTagSortMode.IgnoreArchetypeTags)
        {
            #if GALAH_SAFEMODE
            if(potentialArchetypes.count > 1)
            {
                assertionFailure("There is more than one archetype of this particular composition when archetype tags are off?");
            }
            #endif
            
            idealArchetype = potentialArchetypes[0];
            return idealArchetype;
        }
        
        // Find archetype that fits the tags that fit our criteria.
        
        return idealArchetype;
    }
    
    // Returns true if the specified tag is in use given the archetype tag sort mode. 
    func ArchetypeTagIsInUse(archetypeTag: NodeArchetypeTag) -> Bool
    {
        switch archetypeTagSortMode
        {

        // Always sort all nodes so that nodes in an archetype ALWAYS contain the same tags.
        case NodeArchetypeTagSortMode.MatchArchetypeToTags:
            
            return true;
            
            
        // Ignores archetype tags. Nodes are only sorted into archetypes by their components.
        case NodeArchetypeTagSortMode.IgnoreArchetypeTags:
            
            return false;
        
        // Ignores archetype tags for node sorting aside from those specified in the tag include list.
        case NodeArchetypeTagSortMode.OnlyUseTagsInTagIncludeList:
            
            if(archetypeTagIncludeList[archetypeTag] != nil)
            {
                return true;
            }
            return false;
        
        // Uses archetype tags for sorting aside from those specified in the tag ignore list.
        case NodeArchetypeTagSortMode.OnlyIgnoreTagsInIgnoreList:
            
            if(archetypeTagIgnoreList[archetypeTag] != nil)
            {
                return false;
            }
            return true;
        
        // Use the ignore and include tag lists for node sorting into archetypes. If there's a conflict, the ignore list wins out.
        case NodeArchetypeTagSortMode.UseTagsInTagIncludeListAndIgnoreTagsInIgnoreList:
            
            if( (archetypeTagIncludeList[archetypeTag] != nil) && (archetypeTagIgnoreList[archetypeTag] == nil))
            {
                return true;
            }
            return false;
            
        }
    }

}

public struct ArchetypeTagKeyValuePair: Hashable, Comparable
{
    let key: NodeArchetypeTag;
    let value: String;
    
    init(key: NodeArchetypeTag, value: String)
    {
        self.key = key;
        self.value = value;
    }
    
    public static func < (lhs: ArchetypeTagKeyValuePair, rhs: ArchetypeTagKeyValuePair) -> Bool
    {
        return lhs.key.rawValue < rhs.key.rawValue;
    }
    
    public static func == (lhs: ArchetypeTagKeyValuePair, rhs: ArchetypeTagKeyValuePair) -> Bool
    {
        return (lhs.key == rhs.key) && (lhs.value == rhs.value);
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(key);
        hasher.combine(value);
    }
}
