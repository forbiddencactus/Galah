//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020, 2021, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// NodePool is the class in charge of organising node batches to iterate over.
// Inspired by: https://docs.rs/hecs/0.6.4/hecs/struct.Archetype.html

// typealias this so we can potentially change the type easily if needed.
internal typealias NodeIndex = GIndex;

// TODO: use the indices to pack a bitfield pointing directly to the data?
// TODO: Rewrite this abomination in C, in Swift it's just horrendous and probably slow.
internal class NodePool
{
    private static let poolSizes: Int = 16;
    static let sharedInstance: NodePool = Director.sharedInstance.nodePool;
    
    // NodeIndex acts as an internal index to locate nodes and their components in the batches.
    private var
    nodeIndex: UInt8 = 0;
    private var
    reuseCache = Array<NodeIndex>();
    
    private var
    lookupTable = Dictionary<UInt8, NodeTable>();
    
    // PassBatches are batches per-pass of objects to render, like opaque, transparent, blah.
    private var
    passBatches = Dictionary<String,PassBatch>();
    
    // Scratch buffers:
    // At the end of each frame, Nodes are moved to their most appropriate batches.
    
    // Component scratch buffers are where newly created components go.
    private var
    componentScratchBuffer: Dictionary<HashableType<Component>,ContiguousMutableBuffer>;
    
    // Node scratch buffers are where newly created nodes go.
    private let
    nodeScratchBuffer: ContiguousMutableBufferT<Node>;
    
    // Nodes whose depth or subarchetype types have changed get marked here.
    private var
    nodeDirtyBucket: Array<Node>;
    
    internal init()
    {
    }
    
    // Creates a node.
    internal func CreateNode(transformType: Transform.Type) -> Node?
    {
        let nodeIndex = self.GetNewNodeIndex();
        let ptr: Ptr<Node>;
        
        do
        {
            ptr = try nodeScratchBuffer.MakeSpace(nodeScratchBuffer.Count);
        }
        catch
        {
            return nil;
        }
        
        let newNode: Node? = GObject.Construct(ptr)!;
        if(newNode == nil) { return nil; }
        
        lookupTable[nodeIndex.index] = NodeTable(index: nodeIndex, node: newNode!, components: Array<Component>());
        self.UpdateNode(node: newNode!, table: lookupTable[nodeIndex.index]!);
        
        self.AddComponent(componentType: transformType, node: nodeIndex);
        
        return newNode;
    }
    
    // Updates a node with data from the specified table.
    internal func UpdateNode(node: Node, table: NodeTable)
    {
        node.nodeIndex = table.index;
        node.components = table.components;
    }
    
    // Adds a component to a node.
    @discardableResult
    internal func AddComponent(componentType: Component.Type, node: NodeIndex) -> Component?
    {
        var table: NodeTable? = lookupTable[node.index];
        if(table == nil || table!.index.counter != node.counter) { return nil; }
        
        let componentIndex: ComponentIndex = ComponentIndex(table!.components.count);
        
        let ptr: Ptr<VoidPtr>;
        
        do
        {
            let buffer: ContiguousMutableBuffer? = componentScratchBuffer[componentType];
            
            if(buffer == nil)
            {
                componentScratchBuffer[componentType] = try AllocContiguousBuffer(type: componentType);
            }
            
            ptr = try buffer!.MakeSpace(buffer!.Count);
        }
        catch
        {
            return nil;
        }
        
        let newComponent: Component? = GObject.Construct(type: componentType,ptr: ptr) as! Component?;
        if(newComponent == nil) { return nil;}
        
        newComponent!.componentIndex = componentIndex;
        self.UpdateComponent(component: newComponent!, table: table!);
        
        table!.components.append(newComponent!);
        
        table!.RefreshComponentTypes();
        
        lookupTable[node.index] = table!;
        
        self.UpdateNode(node: table!.node, table: table!);
        
        return newComponent;
    }
    
    // Updates a component with data from the specified table.
    internal func UpdateComponent(component: Component, table: NodeTable)
    {
        component.nodeIndex = table.node.nodeIndex;
        component.node = table.node;
    }
    
    // Gets a node from the lookup table.
    internal func GetNode(_ index: NodeIndex) -> Node?
    {
        let item: NodeTable? = lookupTable[index.index];
        
        if( item?.index.counter == index.counter)
        {
            return item?.node;
        }
    }

    // Removes a node from the lookup table.
    internal func RemoveNode(_ index: NodeIndex)
    {
        let item: NodeTable? = lookupTable[index.index];
        var reuseIndex = index;
        
        if( item?.index.counter == index.counter)
        {
            lookupTable.removeValue(forKey: index.index);
        }
        
        reuseIndex.counter += 1;
        reuseCache.append(reuseIndex);
    }
    
    // Trawls through the scratch buffers and places nodes and their components in the correct archetype. 
    internal func UpdateNodePool()
    {
        // Our update scratch space.
        var updateScratchSpace = Dictionary<UInt8, NodeTable>();
        
        // First, trawl through the node scratch space...
        for i in 0..<nodeScratchBuffer.Count
        {
            // We'll use both the existing lookupTable and this scratch space to determine what lives where.
            let node: Node = try! nodeScratchBuffer.ItemAt(i)!;
            updateScratchSpace[node.nodeIndex.index] = NodeTable(index: node.nodeIndex, node: node);
        }
                        
        // Then, trawl through the component scratch space, and add nodes.
        for compType in componentScratchBuffer.keys
        {
            let compBuff = componentScratchBuffer[compType]! as! ContiguousMutableBufferT<Component>
            for i in 0..<compBuff.Count
            {
                let component: Component = try! compBuff.ItemAt(i)!;
                var updateTable: NodeTable? = updateScratchSpace[component.nodeIndex.index];
                let parentNode: Node = component.Node;
                
                if(updateTable == nil)
                {
                    updateTable = NodeTable(index: parentNode.nodeIndex, node: parentNode);
                }
                
                updateTable!.components.append(component);
                
                updateScratchSpace[parentNode.nodeIndex.index] = updateTable!;
            }
        }
        
        // At this point, we should have a list of what nodes and their components need to be updated.
        // We should have also have an idea of where they live.
        
        for nodetable in updateScratchSpace.values
        {
            let passIndex = nodetable.node.GetPassIndex();
            var node = nodetable.node;
            let subBatchIndex = nodetable.node.GetSubArchetypeBatchIndex();
            var masterTable = lookupTable[nodetable.index.index]!;
            
            if(passBatches[passIndex] == nil)
            {
                passBatches[passIndex] = PassBatch(Index: passIndex);
            }
            
            let depthIndex = passBatches[passIndex]!.GetIndexForDepth(depth: nodetable.node.Depth);
            
            if(passBatches[passIndex]!.DepthBatches[depthIndex].ArchetypeBatch[masterTable.componentTypes] == nil)
            {
                let archeType = NodeArchetype.CreateArchetype(nodeTable: masterTable);
                passBatches[passIndex]!.DepthBatches[depthIndex].ArchetypeBatch[nodetable.componentTypes] = archeType;
            }
        if(passBatches[passIndex]!.DepthBatches[depthIndex].ArchetypeBatch[masterTable.componentTypes]?.SubArchetypeBatch[subBatchIndex] == nil)
            {
                let subArchetypeBatch = SubArchetypeBatch(batchID: subBatchIndex);
            passBatches[passIndex]!.DepthBatches[depthIndex].ArchetypeBatch[masterTable.componentTypes]?.SubArchetypeBatch[subBatchIndex] = subArchetypeBatch;
            }
            
            let index: Int = try! (passBatches[passIndex]!.DepthBatches[depthIndex].ArchetypeBatch[masterTable.componentTypes]?.SubArchetypeBatch[subBatchIndex]!.NodeBuffer.Add(node))!;
            
            node.HasBeenCopied();
            try! passBatches[passIndex]!.DepthBatches[depthIndex].ArchetypeBatch[masterTable.componentTypes]!.SubArchetypeBatch[subBatchIndex]!.NodeBuffer.ItemAt(index)!.IsCopied();
            
            if(!masterTable.nodeParentBuffer.IsNull())
            {
                // There's an existing owning buffer which owns this node.
                masterTable.nodeParentBuffer.RunFunc
                {
                    try! $0.NodeBuffer.Remove(masterTable.nodeParentBufferIndex);
                }
            }
            else
            {
                // The node lives in the scratch buffer.
            }
            
            for component in masterTable.components
            {
                // A horrendous brute force solution.
                // TODO: In contiguousmutablebuffer, we can probably do some pointer magic to ameliorate this?
                var contains: Bool = false;

                for theComponent in updateScratchSpace[node.nodeIndex.index]!.components
                {
                    if( theComponent == component)
                    {
                        contains = true;
                    }
                }
                
                if(!contains)
                {
                    passBatches[passIndex]!.DepthBatches[depthIndex].ArchetypeBatch[masterTable.componentTypes]!.SubArchetypeBatch[subBatchIndex]!.BatchMembers[component.self].;
                    masterTable.nodeParentBuffer.RunFunc {$0.BatchMembers}
                }
            }
            
            nodeScratchBuffer.Clear();
            componentScratchBuffer.removeAll();
            
        }
    }
    
    internal func MarkDirty(node: Node)
    {
        nodeDirtyBucket.append(node);
    }
    
    private func AllocContiguousBuffer(type: GObject.Type) throws -> ContiguousMutableBuffer
    {
        return try ContiguousMutableBuffer(withType: type, withInitialCapacity: NodePool.poolSizes);
    }
    
    // Returns a unique object index for a new object.
    private func GetNewNodeIndex() -> NodeIndex
    {
        if( reuseCache.count > 0 )
        {
            let index = reuseCache.last!;
            reuseCache.removeLast();
            return index;
        }
        else
        {
            if(nodeIndex < UInt8.max)
            {
                let index = NodeIndex(index: nodeIndex, counter: UInt8.zero);
                nodeIndex += 1;
                return index;
            }
            else
            {
                // Uh... you have WAY too many objects.
                fatalError();
                return NodeIndex();
            }
        }
    }

    // Sort batches by BatchId (material type, texture, etc).
    struct SubArchetypeBatch
    {
        public var NodeBuffer = try! ContiguousMutableBufferT<Node>(withInitialCapacity: 16);
        public var BatchId: String;
        public var BatchMembers = Dictionary<HashableType<GObject>, ContiguousMutableBuffer>();
        
        public init(batchID: String)
        {
            self.BatchId = batchID;
        }
        
        public func GetComponentForNodeExists(nodeBatchIndex: Int, componentIndex: ComponentIndex) -> Bool
        {
            return false;
        }
    }
    
    // Sort batches by archetypes of nodes with exactly the same components.
    struct NodeArchetype
    {
        public var SubArchetypeBatch: Dictionary<String,SubArchetypeBatch>;
        public var ComponentBatchTypes: Dictionary<HashableType<Component>, Int>;
        public var ComponentBatchTypeArray: Array<HashableType<Component>>;
        
        // Create an archetype for the specified nodetable.
        public static func CreateArchetype(nodeTable: NodeTable) -> NodeArchetype
        {
            var allTypes = Dictionary<HashableType<Component>, Int>();
            
            for componentType in nodeTable.componentTypes
            {
                if(allTypes[componentType] == nil)
                {
                    allTypes[componentType] = 1;
                }
                else
                {
                    allTypes[componentType]! += 1;
                }
                
                var type = ClassMetadata(type: componentType.base);
                
                var hasSuper = true;
                while(hasSuper)
                {
                    let theSuper = type.superClassMetadata();
                    if(theSuper != nil)
                    {
                        type = theSuper!.asClassMetadata()!;
                        let fType = HashableType<Component>(unsafeBitCast(type.pointer, to: Component.Type.self));

                        if(allTypes[fType] == nil)
                        {
                            allTypes[fType] = 1;
                        }
                        else
                        {
                            allTypes[fType]! += 1;
                        }
                    }
                    else
                    {
                        hasSuper = false;
                    }
                }

            }
            
            return NodeArchetype(SubArchetypeBatch: Dictionary<String,SubArchetypeBatch>(), ComponentBatchTypes: allTypes, ComponentBatchTypeArray: nodeTable.componentTypes);
        }

    }
    
    // Sort batches by depth
    struct DepthBatch
    {
        public let Depth: Int;
        public var ArchetypeBatch: Dictionary<Array<HashableType<Component>>,NodeArchetype>;
    }
    
    // PassBatches are batches per-pass of objects to render, like opaque, transparent, blah.
    struct PassBatch
    {
        public let Index: String;
        public var DepthBatches = Array<DepthBatch>();
        
        // Returns the correct index for the supplied depth, creating it if required.
        public func GetIndexForDepth(depth: Int) -> Int
        {
            
        }
    }
    
    struct NodeTable
    {
        // If this is null, node is childed to scratch buffers.
        var nodeParentBuffer = Ptr<SubArchetypeBatch>.Null();
        var nodeParentBufferIndex: Int = 0;
        var index: NodeIndex;
        var node: Node;
        var components = Array<Component>();
        var componentTypes = Array<HashableType<Component>>();

        public mutating func RefreshComponentTypes()
        {
            componentTypes.removeAll(keepingCapacity: true);
            
            for component: Component in components
            {
                componentTypes.append(HashableType<Component>(type(of: component)));
            }
        }
    }
    
    
    
}
