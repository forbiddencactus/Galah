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
// NodeBank is the class in charge of organising node batches into archetypes.
// Inspired by all the awesome work on ECS systems out there.

// NEW IDEA: contiguous buffers still, but this time only organised by 'tag'. There can be a tag for depth, material texture, whatever.
internal struct NodeBank
{
    internal var idBank = NodeIDBank();
    internal var ptrBank = NodePtrBank();
    
    internal var nodeArchetypes = ContiguousDictionary<NodeArchetypeID,NodeArchetype>();
    internal var transientNodes = Array<Node>();
    internal var transientComponents = ContiguousDictionary<ComponentType,Buffer<Component>>();
    
    /* ****************
    Node creation...
    **************** */
    
    // Creates a node with the specified empty components.
    internal mutating func CreateNode(components: Array<Component.Type>) -> Node
    {
        // TODO:
        let components = Array<Component>();
        return CreateNode(components: components)
    }
    
    // Creates a node with the input components.
    internal mutating func CreateNode(components: Array<Component>) -> Node
    {
        // TODO:
        let array = Array<Ptr<Component>>();
        let node = Node(nodeID: idBank.Pop(), components: array);
        
        return node;
    }
    
    /* ****************
    Node fetching...
    **************** */
    
    // Returns the node pointed to by NodeID. 
    internal func GetNode(id: NodeID) -> Node?
    {
        if( ptrBank.GetNodeExists(nodeID: id))
        {
            return ptrBank[id].pointee;
        }
        
        return nil;
    }
}


