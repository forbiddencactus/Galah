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
// Archetype Tags are used as a way to further batch archetypes.

// Each node has a set of tags, determined by its components.
// Sort mode determines how to use its tags to create node archetypes.
public enum NodeArchetypeTagSortMode
{
    // Always sort all nodes so that nodes in an archetype ALWAYS contain the same tags.
    MatchArchetypeToTags,
    
    // Ignores archetype tags. Nodes are only sorted into archetypes by their components.
    IgnoreArchetypeTags,
    
    // Ignores archetype tags for node sorting aside from those specified in the tag include list.
    OnlyUseTagsInTagIncludeList,
    
    // Uses archetype tags for sorting aside from those specified in the tag ignore list.
    OnlyIgnoreTagsInIgnoreList,
    
    // Use the ignore and include tag lists for node sorting into archetypes. If there's a conflict, the ignore list wins out.
    UseTagsInTagIncludeListAndIgnoreTagsInIgnoreList,
}

// The various types of node archetype tags that can be set...
public enum NodeArchetypeTag
{
    // Node tags...
    
    NodeDepth,
    
    // Render tags...
    
    // Render Pass tags...
    RenderPassOpaque,
    RenderPassTransparent,
    
    // Materials...
    MaterialName,
    MaterialTextures,
    MaterialResources,
}
