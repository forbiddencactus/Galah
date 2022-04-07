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

internal struct NodeArchetypeMap
{
    var archetypeTypes = Dictionary<HashableType<Component>,Array<NodeArchetypeID>>();
    var archetypeTags = Dictionary<ArchetypeTagKeyValuePair, Array<NodeArchetypeID>>();

}

internal struct ArchetypeTagKeyValuePair: Hashable
{
    let key: NodeArchetypeTag;
    let value: String;
    
    init(key: NodeArchetypeTag, value: String)
    {
        self.key = key;
        self.value = value;
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(key);
        hasher.combine(value);
    }
}
