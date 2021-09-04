//---- Galah Engine---------------------------------------------------------//
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

// typealias this so we can potentially change the type easily if needed.
internal typealias NodeIndex = UInt64;

internal class NodePool
{
    static let sharedInstance: NodePool = Director.sharedInstance.nodePool;
    
    // NodeIndex acts as an internal index to locate nodes and their components in the batches.
    private var
    nodeIndex: NodeIndex = 0;
    
    private let
    lookupTable = Dictionary<NodeIndex, NodeTable>();
    
    // PassBatches are batches per-pass of objects to render, like opaque, transparent, blah.
    private let
    passBatches = Array<PassBatch>();
    
    // Scratch buffers:
    // At the end of each frame, Nodes are moved to their most appropriate batches.
    
    // Component scratch buffers are where newly created components go.
    private let
    componentScratchBuffer = Dictionary<HashableType<Component>, ContiguousMutableBuffer<Component>>();
    
    // Node scratch buffers are where newly created nodes go.
    private let
    nodeScratchBuffer = Dictionary<NodeIndex, ContiguousMutableBuffer<Node>>();
    
    // Gets the current node index and increments the counter.
    internal func GetNewNodeIndex() -> NodeIndex
    {
        let returnVal = nodeIndex;
        nodeIndex += 1;
        return returnVal;
    }

    struct ComponentSubBatch
    {
        let NodeBuffer: ContiguousMutableBuffer<Node>;
        public let BatchId: String;
        public let BatchMembers: Dictionary<HashableType<GObject>, ContiguousMutableBuffer<Component>>;
    }
    
    struct ComponentBatch
    {
        public let DepthPool: Array<DepthBatch>;
        public let ComponentBatchTypes: Dictionary<HashableType<Component>, Int>;
    }
    
    struct DepthBatch
    {
        public let Depth: Int;
        public let ComponentSubBatch: Array<ComponentSubBatch>;
    }
    
    struct PassBatch
    {
        public let Index: Int;
        public let ComponentBatch: Array<ComponentBatch>;
    }
    
    struct NodeTable
    {
        var node: Node;
        var components: Array<Component>;
    }
    
    
    
}
