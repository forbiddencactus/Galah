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
    internal var Components = ContiguousDictionary<ComponentType,Buffer<Component>>();
    
    internal init(archetypeID: NodeArchetypeID)
    {
        self.archetypeID = archetypeID;
        
        let selfPtr: VoidPtr = glh_pointer_get(&self);
        Nodes.BufferElementsMovedEvent.Subscribe(selfPtr, NodeBufferElementsMoved);
        Nodes.BufferResizedEvent.Subscribe(selfPtr, NodeBufferResized);
    }
    
    // Adds a node and its components to the archetype, and updates the node.
    internal mutating func AddNode(nodeID: NodeID, components: Array<Component>) -> NodeLocation
    {
        var node = Node(nodeID: nodeID);
        let nodeIndex = try! Nodes.Add(&node);
        var theNodeData = NodeData();
        let dataIndex = try! NodeDatas.Add(&theNodeData);
        assert(dataIndex == nodeIndex, "NodeIndex and Data index should be the same!")
        let dataPtr: Ptr<NodeData> = try! NodeDatas.PtrAt(dataIndex);
                
        for component in components
        {
            let componentIndex = UInt8(dataPtr.pointee.Components.count);
            if(componentIndex >= UInt8.max) { fatalError("Your Node has too many components!"); }
            let componentNodeID = NodeID(nodeID: nodeID, componentIndex: componentIndex);
            let componentPtr = self.AddComponent(nodeID: componentNodeID, component: component);
            dataPtr.pointee.Components.append(componentPtr);
        }
        
        return NodeLocation(archetype: archetypeID, index: UInt32(nodeIndex));
    }
    
    // Adds the specified component to the specified nodeID.
    internal mutating func AddComponent(nodeID: NodeID, component: Component) -> Ptr<Component>
    {
        let theType: ComponentType = ComponentType(type(of: component));
        var componentHeader = component.CreateComponentHeader(nodeID: nodeID);

        if(Components[theType] == nil)
        {
            let headerType = type(of: componentHeader);
            var componentBuffer = try! Buffer<Component>(withType: headerType);
            Components[theType] = componentBuffer;
            
            componentBuffer.BufferElementsMovedEvent.Subscribe(glh_pointer_get(&self), ComponentBufferElementsMoved);
            componentBuffer.BufferResizedEvent.Subscribe(glh_pointer_get(&self), ComponentBufferResized);
        }
        
        let componentIndex = try! Components[theType]!.Add(componentHeader.GetPtr());
        return try! Components[theType]!.PtrAt(componentIndex);
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
    
    
    // Callbacks
    func NodeBufferElementsMoved(buffer: inout Buffer<Node>)
    {
        for index in 0..<Nodes.Count
        {
            let nodeID = try! Nodes.PtrAt(index).pointee._nodeID;
            let nodeLocation = NodeLocation(archetype: archetypeID, index: UInt32(index));
            Director.sharedInstance.nodeBank.ptrBank.UpdatePath(nodeID: nodeID, nodeLocation: nodeLocation);
        }
    }
    
    func NodeBufferResized(buffer: inout Buffer<Node>)
    {
        for index in 0..<Nodes.Count
        {
            let nodeID = try! Nodes.PtrAt(index).pointee._nodeID;
            let nodeLocation = NodeLocation(archetype: archetypeID, index: UInt32(index));
            Director.sharedInstance.nodeBank.ptrBank.UpdatePath(nodeID: nodeID, nodeLocation: nodeLocation);
        }
    }
    
    func ComponentBufferElementsMoved(buffer: inout Buffer<Component>)
    {
        for index in 0..<buffer.Count
        {
            let componentPtr: Ptr<Component> = try! buffer.PtrAt(index);
            let componentHeaderPtr: Ptr<PComponentHeader> = Cast(componentPtr);
            let nodeID = componentHeaderPtr.pointee.GetNodeID();
            NodeHelpers.GetNodeData(nodeID).pointee.ReplaceComponent(index: nodeID.componentIndex, ptr: componentPtr);
        }
    }
    
    func ComponentBufferResized(buffer: inout Buffer<Component>)
    {
        
    }
}
