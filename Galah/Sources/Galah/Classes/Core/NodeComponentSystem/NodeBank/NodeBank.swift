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
    internal var archetypeMap = NodeArchetypeMap();
    internal var archetypeStore = NodeArchetypeStore();
    
    /* ****************
    Node creation...
    **************** */
    
    // Creates a node with the specified empty components.
    internal mutating func CreateNode(components: inout Array<ComponentType>, depth: UInt = 0) -> Node
    {
        components.sort();
        var instantiatedComponents = Array<Component>();
        
        for component in components
        {
            instantiatedComponents.append(component.type.init());
        }
        
        return CreateNode(components: &instantiatedComponents)
    }
    
    // Creates a node with the input components.
    internal mutating func CreateNode(components: inout Array<Component>, depth: UInt = 0) -> Node
    {
        let newNodeID = idBank.Pop();
        var componentTypeIndices = Array<ComponentTypeIndexKVPair>();
        var componentTypes = Array<ComponentType>();
        
        for index in 0..<components.count
        {
            let component = components[index];
            let theType = type(of: component);
            
            let componentType = ComponentType(theType);
            let kvPair = ComponentTypeIndexKVPair(componentType: componentType, index: index);
            componentTypeIndices.append(kvPair);
            componentTypes.append(componentType);
        }
        componentTypes.sort();
        componentTypeIndices.sort();
                
        var componentPtrArray = Array<Ptr<Component>>();
        
        for kvPair in componentTypeIndices
        {
            componentPtrArray.append(&components[kvPair.index]);
        }
        
        var node = Node(nodeID: newNodeID, components: componentPtrArray, depth: depth);
        let nodeArchetypeTags = node.GetArchetypeTags();
        
        var potentialArchetypes = Array<NodeArchetypeID>();
        var archetypeID: NodeArchetypeID? = archetypeMap.GetArchetypeForNodeComposition(nodeComponentTypes: componentTypes, nodeArchetypeTags: nodeArchetypeTags, potentialArchetypes: &potentialArchetypes);
        let archetype: Ptr<NodeArchetype>;
        
        if(archetypeID != nil)
        {
            archetype = archetypeStore.GetArchetype(archetypeID: archetypeID!);
        }
        else
        {
            if(potentialArchetypes.count > 0)
            {
                assertionFailure("TODO: Do this!");
                archetype = archetypeStore.GetArchetype(archetypeID: potentialArchetypes[0]);
            }
            else
            {
                archetypeID = archetypeStore.CreateArchetype();
                archetypeMap.AddArchetype(archetypeID: archetypeID!, nodeComponentTypes: componentTypes, nodeArchetypeTags: nodeArchetypeTags);
                archetype = archetypeStore.GetArchetype(archetypeID: archetypeID!);
            }
        }
        
        return archetype.pointee.AddNode(node: &node, components: &componentPtrArray);        
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


fileprivate struct ComponentTypeIndexKVPair: Comparable
{
    let componentType: ComponentType;
    let index: Int;

    static func < (lhs: ComponentTypeIndexKVPair, rhs: ComponentTypeIndexKVPair) -> Bool
    {
        return lhs.componentType < rhs.componentType;
    }
    
    static func == (lhs: ComponentTypeIndexKVPair, rhs: ComponentTypeIndexKVPair) -> Bool
    {
        return lhs.componentType == rhs.componentType;
    }
}
