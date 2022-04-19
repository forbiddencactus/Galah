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

import GalahNative.Memory;

internal struct NodeArchetype
{
    private var archetypeID: NodeArchetypeID;
    
    // The component types that live in this archetype.
    internal var ComponentTypeArray = Array<ComponentType>();
    internal var ArchetypeTags = Array<ArchetypeTagKeyValuePair>();
    
    internal var Nodes = try! Buffer<Node>();
    internal var NodeDatas = try! Buffer<NodeData>();
    internal var ComponentDatas = try! Buffer<ComponentData>();
    internal var Components = ContiguousDictionary<ComponentType,Buffer<Component>>();
    
    internal init(archetypeID: NodeArchetypeID)
    {
        self.archetypeID = archetypeID;
        
        let selfPtr: Ptr<NodeArchetype> = Cast(glh_pointer_get(&self));
        
        Nodes.BufferElementsMovedEvent.Subscribe(selfPtr, NodeBufferElementsMoved);
        Nodes.BufferResizedEvent.Subscribe(selfPtr, NodeBufferElementsMoved);
    }
    
    // Adds a node and its components to the archetype, and updates the node.
    internal mutating func AddNode(nodeID: NodeID, components: Array<Component>) -> NodeLocation
    {
        var node = Node(nodeID: nodeID);
        let nodeIndex = try! Nodes.Add(&node);
        var theNodeData = NodeData();
        let dataIndex = try! NodeDatas.Add(&theNodeData);
        assert(dataIndex == nodeIndex, "NodeIndex and Data index should be the same!")
                
        for component in components
        {
            _ = self.AddComponent(nodeID: nodeID, component: component, nodeIndex: nodeIndex);
        }
        
        return NodeLocation(archetype: archetypeID, index: UInt32(nodeIndex));
    }
    
    // Adds the specified component to the specified nodeID.
    internal mutating func AddComponent(nodeID: NodeID, component: Component, nodeIndex: UInt? = nil) -> Ptr<Component>
    {
        let componentDataPtr = nodeIndex != nil ? try! ComponentDatas.PtrAt(UInt(nodeIndex!)) : NodeHelpers.GetComponentData(nodeID);
        let componentIndex = UInt8(componentDataPtr.pointee.Components.count);
        if(componentIndex >= UInt8.max) { fatalError("Your Node has too many components!"); }
        let componentNodeID = NodeID(nodeID: nodeID, componentIndex: componentIndex);

        let theType: ComponentType = ComponentType(type(of: component));
        var componentHeader = component.CreateComponentHeader(nodeID: componentNodeID);

        if(Components[theType] == nil)
        {
            let headerType = type(of: componentHeader);
            var componentBuffer = try! Buffer<Component>(withType: headerType);
            Components[theType] = componentBuffer;
            
            componentBuffer.BufferElementsMovedEvent.Subscribe(glh_pointer_get(&self), ComponentBufferElementsMoved);
            componentBuffer.BufferResizedEvent.Subscribe(glh_pointer_get(&self), ComponentBufferResized);
        }
        
        let componentArrayIndex = try! Components[theType]!.Add(componentHeader.GetPtr());
        let componentPtr = try! Components[theType]!.PtrAt(componentArrayIndex);
        componentDataPtr.pointee.Components.append(componentPtr);
        componentDataPtr.pointee.ComponentArrayIndices.append(componentArrayIndex);
        componentDataPtr.pointee.ComponentTypes.append(theType);
        componentDataPtr.pointee.ComponentArchetype.append(archetypeID);

        return componentPtr;
    }
    
    internal mutating func RemoveNode(nodeID: NodeID, nodeIndex: UInt? = nil)
    {
        let theNodeIndex = UInt(nodeIndex != nil ? UInt32(nodeIndex!) : NodeHelpers.GetNodeLocation(nodeID).index);
        assert(try! Nodes.PtrAt(theNodeIndex).pointee._nodeID == nodeID);
        let componentDataPtr = try! ComponentDatas.PtrAt(theNodeIndex);
        
        for index in 0..<componentDataPtr.pointee.Components.count
        {
            let componentNodeID = NodeID(nodeID: nodeID, componentIndex: UInt8(index));
            self.RemoveComponent(componentID: componentNodeID, nodeIndex: theNodeIndex);
        }
        
        try! Nodes.Remove(theNodeIndex);
        try! NodeDatas.Remove(theNodeIndex);
        try! ComponentDatas.Remove(theNodeIndex);
        
        self.UpdateNodePaths();
    }
    
    // Removes the specified component from the specified nodeID with component info.
    internal mutating func RemoveComponent(componentID: NodeID, nodeIndex: UInt? = nil)
    {
        // You should only really run this when removing nodes, if the node is mutating, it should change archetype.
        let componentIndex = componentID.componentIndex;
        let componentDataPtr = nodeIndex != nil ? try! ComponentDatas.PtrAt(UInt(nodeIndex!)) : NodeHelpers.GetComponentData(componentID);
        let componentArrayIndex = componentDataPtr.pointee.ComponentArrayIndices[Int(componentIndex)];
        let componentType = componentDataPtr.pointee.ComponentTypes[Int(componentIndex)];
        
        componentDataPtr.pointee.ComponentArchetype.remove(at: Int(componentIndex));
        componentDataPtr.pointee.Components.remove(at: Int(componentIndex));
        componentDataPtr.pointee.ComponentTypes.remove(at: Int(componentIndex));
        componentDataPtr.pointee.ComponentArrayIndices.remove(at: Int(componentIndex));
        
        try! Components[componentType]!.Remove(componentArrayIndex);
        
        if(Components[componentType]!.Count == 0)
        {
            Components.RemoveKey(componentType);
        }
        else
        {
            UpdateNodeComponentPaths(componentBuffer: &Components[componentType]!);
        }
    }
    
    // Returns a pointer to the node at the specified index in the archetype.
    internal func GetNode(index: UInt32) -> Ptr<Node>
    {
        return try! Nodes.PtrAt(UInt(index));
    }
    
    // Returns a pointer to the node data at the specified index in the archetype.
    internal func GetNodeData(index: UInt32) -> Ptr<NodeData>
    {
        return try! NodeDatas.PtrAt(UInt(index));
    }
    
    // Returns a pointer to the node's component data at the specified index in the archetype.
    internal func GetComponentData(index: UInt32) -> Ptr<ComponentData>
    {
        return try! ComponentDatas.PtrAt(UInt(index));
    }
    
    internal func GetNodeCount() -> UInt
    {
        return Nodes.Count;
    }
    
    // Callbacks
    func NodeBufferElementsMoved(buffer: inout Buffer<Node>)
    {
        UpdateNodePaths();
    }
    
    func NodeBufferResized(buffer: inout Buffer<Node>)
    {
        UpdateNodePaths();
    }
    
    func ComponentBufferElementsMoved(buffer: inout Buffer<Component>)
    {
        self.UpdateNodeComponentPaths(componentBuffer: &buffer);
    }
    
    func ComponentBufferResized(buffer: inout Buffer<Component>)
    {
        self.UpdateNodeComponentPaths(componentBuffer: &buffer);
    }
    
    func UpdateNodePaths()
    {
        for index in 0..<Nodes.Count
        {
            let nodePtr = try! Nodes.PtrAt(UInt(index));
            let nodeID = nodePtr.pointee._nodeID;
            let nodeLocation = NodeLocation(archetype: archetypeID, index: UInt32(index));
            Director.sharedInstance.nodeBank.ptrBank.UpdatePath(nodeID: nodeID, nodeLocation: nodeLocation);
        }
    }
    
    func UpdateNodeComponentPaths(componentBuffer: inout Buffer<Component>)
    {
        let componentType = ComponentType(componentBuffer.ElementType as! Component.Type);
        var prevNodeID: NodeID = NodeID();
        var nodeCount: UInt = 0;
        for index in 0..<componentBuffer.Count
        {
            let componentPtr: Ptr<Component> = try! componentBuffer.PtrAt(UInt(index));
            let componentHeaderPtr: Ptr<PComponentHeader> = Cast(componentPtr);
            let nodeID = componentHeaderPtr.pointee.GetNodeID();
            
            if(prevNodeID != nodeID)
            {
                prevNodeID = nodeID;
                nodeCount = 0;
            }
            let componentDataPtr = NodeHelpers.GetComponentData(nodeID);
            let firstIndexForType = UInt(componentDataPtr.pointee.ComponentTypes.firstIndex(of: componentType)!);

            componentDataPtr.pointee.ComponentArrayIndices[Int(firstIndexForType + nodeCount)] = index;
            componentDataPtr.pointee.Components[Int(firstIndexForType + nodeCount)] = componentPtr;
            
            nodeCount += 1;
        }
    }
}
