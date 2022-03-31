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
// Node Archetypes are the way to group nodes and their components into contiguous batches.

internal struct NodeArchetype
{
    // The component types that live in this archetype.
    internal var ComponentTypes = Dictionary<HashableType<Component>, Int>();
    internal var ComponentTypeArray = Array<HashableType<Component>>();
    internal var ArchetypeTags = Dictionary<NodeArchetypeTag, String>();
    
    internal var Nodes = try! Buffer<Node>();
    internal var Components = ContiguousDictionary<HashableType<Component>,Buffer<Component>>();
}
