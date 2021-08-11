//
//  File.swift
//  
//
//  Created by Alex Griffin on 11/8/21.
//

import Foundation

internal class NodePool
{
    struct ComponentPoolBatch
    {
        public let NodeBuffer: ContiguousMutableBuffer<Node>;
        public let BatchId: String;
        public let BatchMembers: Dictionary<Type,ContiguousMutableBuffer<Component>>;
    }
    
    struct ComponentPool
    {
        public let BatchPool: Array<ComponentPoolBatch>;
        public let BatchTypes: Dictionary<Component, Bool>;
    }
    
    struct DepthPool
    {
        public let Depth: Int;
        public let ComponentPools: Array<ComponentPool>;
    }
    
    public let DepthPools: Array<DepthPool>;
    
    
}
