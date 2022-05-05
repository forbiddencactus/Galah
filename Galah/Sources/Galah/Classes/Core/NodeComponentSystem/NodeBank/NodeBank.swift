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
    internal mutating func CreateNode(components: inout Array<ComponentType>, nodeData: NodeData = NodeData()) -> Node
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
    internal mutating func CreateNode(components: inout Array<Component>, nodeData: NodeData = NodeData()) -> Node
    {
        let newNodeID = idBank.Pop();
        var componentTypeIndices = Array<ComponentTypeIndexKVPair>();
        var componentTypes = Array<ComponentType>();
        
        for index in 0..<components.count
        {
            let component = components[index];
            let theType = type(of: component);
            
            if(theType is AnyClass)
            {
                assertionFailure("Only value types can be used as components!");
            }
            
            let componentType = ComponentType(theType);
            let kvPair = ComponentTypeIndexKVPair(componentType: componentType, index: index);
            componentTypeIndices.append(kvPair);
            componentTypes.append(componentType);
        }
        componentTypes.sort();
        componentTypeIndices.sort();
                
        var componentArray = Array<Component>();
        
        for kvPair in componentTypeIndices
        {
            componentArray.append(components[kvPair.index]);
        }
        
        let archetype = self.GetOrMakeArchetypeForNode(nodeData: nodeData, components: componentArray, componentTypes: componentTypes);
       
        let nodeLocation = archetype.pointee.AddNode(nodeID: newNodeID, components: componentArray, nodeData: nodeData);
        ptrBank.AddNode(nodeID: newNodeID, nodeLocation: nodeLocation);
        return NodeHelpers.GetNode(newNodeID).pointee;
    }
    
    internal mutating func MoveNode(nodeID: NodeID, toArchetype: Ptr<NodeArchetype>)
    {
        var components = Array<Component>();
        let nodeData = NodeHelpers.GetNodeData(nodeID);
        let componentData = NodeHelpers.GetComponentData(nodeID);
        let currentNodeLocation = NodeHelpers.GetNodeLocation(nodeID);
        
        for component in componentData.pointee.Components
        {
            components.append(component.pointee);
        }
        
        archetypeStore.GetArchetype(archetypeID: currentNodeLocation.archetype).pointee.RemoveNode(nodeID: nodeID);
        
        let newNodeLocation = toArchetype.pointee.AddNode(nodeID: nodeID, components: components, nodeData: nodeData.pointee);
        
        ptrBank.UpdatePath(nodeID: nodeID, nodeLocation: newNodeLocation);
    }
    
    /* ****************
    Node fetching...
    **************** */
    
    // Returns the node pointed to by NodeID. 
    //internal func GetNode(id: NodeID) -> Node?
    //{
        //if( ptrBank.GetNodeExists(nodeID: id))
        //{
            //return ptrBank[id].pointee;
        //}
        
        //return nil;
    //}
    
    
    //Placeholder...
    internal func MarkDirty(nodeID: NodeID)
    {
        
    }
    
    internal mutating func GetOrMakeArchetypeForNode(nodeData: NodeData, components: [Component], componentTypes: [ComponentType]) -> Ptr<NodeArchetype>
    {
        
        
        let nodeArchetypeTags = NodeArchetypeHelpers.GetArchetypeTags(nodeData: nodeData, components: components);

        
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
        
        return archetype;
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
