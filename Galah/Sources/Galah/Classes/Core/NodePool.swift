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
internal class NodePool
{
    static let sharedInstance: NodePool = Director.sharedInstance.nodePool;
    
    // NodeIndex acts as an internal index to locate nodes and their components in the batches.
    private var
    nodeIndex: UInt8 = 0;
    private var
    reuseCache = Array<NodeIndex>();
    
    private var
    lookupTable = Dictionary<UInt8, NodeTable>();
    
    // PassBatches are batches per-pass of objects to render, like opaque, transparent, blah.
    private let
    passBatches = Array<PassBatch>();
    
    // Scratch buffers:
    // At the end of each frame, Nodes are moved to their most appropriate batches.
    
    // Component scratch buffers are where newly created components go.
    private let
    componentScratchBuffer: ContiguousMutableBuffer<Component>;
    
    // Node scratch buffers are where newly created nodes go.
    private let
    nodeScratchBuffer: ContiguousMutableBuffer<Node>;
    
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
    
    internal func UpdateNode(node: Node, table: NodeTable)
    {
        node.nodeIndex = table.index;
        node.components = table.components;
    }
    
    @discardableResult
    internal func AddComponent(componentType: Component.Type, node: NodeIndex) -> Component?
    {
        var table: NodeTable? = lookupTable[node.index];
        if(table == nil || table!.index.counter != node.counter) { return nil; }
        
        let componentIndex: ComponentIndex = ComponentIndex(table!.components.count);
        
        let ptr: Ptr<Component>;
        
        do
        {
            ptr = try componentScratchBuffer.MakeSpace(componentScratchBuffer.Count);
        }
        catch
        {
            return nil;
        }
        
        let newComponent: Component? = GObject.Construct(ptr);
        if(newComponent == nil) { return nil;}
        
        newComponent!.componentIndex = componentIndex;
        self.UpdateComponent(component: newComponent!, table: table!);
        
        table!.components.append(newComponent!);
        
        lookupTable[node.index] = table!;
        
        self.UpdateNode(node: table!.node, table: table!);
        
        return newComponent;
    }
    
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
    struct ArchetypeSubBatch
    {
        let NodeBuffer: ContiguousMutableBuffer<Node>;
        public let BatchId: String;
        public let BatchMembers: Dictionary<HashableType<GObject>, ContiguousMutableBuffer<Component>>;
    }
    
    // Sort batches by archetypes of nodes with exactly the same components.
    struct NodeArchetype
    {
        public let DepthPool: Array<DepthBatch>;
        public let ComponentBatchTypes: Dictionary<HashableType<Component>, Int>;
        public let ComponentBatchTypeArray: Array<HashableType<Component>>;

    }
    
    // Sort batches by depth
    struct DepthBatch
    {
        public let Depth: Int;
        public let ComponentSubBatch: Array<ArchetypeSubBatch>;
    }
    
    // PassBatches are batches per-pass of objects to render, like opaque, transparent, blah.
    struct PassBatch
    {
        public let Index: Int;
        public let ComponentBatch: Array<NodeArchetype>;
    }
    
    struct NodeTable
    {
        var index: NodeIndex;
        var node: Node;
        var components: Array<Component>;
    }
    
    
    
}
