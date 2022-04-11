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
    internal let archetypeID: NodeArchetypeID;
    
    // The component types that live in this archetype.
    internal var ComponentTypeArray = Array<ComponentType>();
    internal var ArchetypeTags = Array<ArchetypeTagKeyValuePair>();
    
    internal var Nodes = try! Buffer<Node>();
    internal var Components = ContiguousDictionary<ComponentType,Buffer<Component>>();
    
    // Adds a node and its components to the archetype, and updates the node. 
    internal mutating func AddNode(node: inout Node, components: inout Array<Ptr<Component>>) -> Node
    {
        let nodeIndex = try! Nodes.Add(&node);
        let nodePtr: Ptr<Node> = try! Nodes.PtrAt(nodeIndex);
        
        nodePtr.pointee._components.removeAll();
        
        for componentPtr in components
        {
            let theType: ComponentType = ComponentType(type(of: componentPtr.pointee));
            var componentHeader = componentPtr.pointee.CreateComponentHeader(nodeID: node._nodeID);

            if(Components[theType] == nil)
            {
                let headerType = type(of: componentHeader);
                Components[theType] = try! Buffer<Component>(withType: headerType);
            }
            
            let componentIndex = try! Components[theType]!.Add(componentHeader.GetPtr());
            let componentPtr: Ptr<Component> = try! Components[theType]!.PtrAt(componentIndex);
            
            nodePtr.pointee._components.append(componentPtr);
        }
        
        return nodePtr.pointee;
    }
}
