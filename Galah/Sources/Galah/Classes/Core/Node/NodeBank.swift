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
// NodePool is the class in charge of organising node batches to iterate over.
// Inspired by all the awesome work on ECS systems out there.

// NEW IDEA: contiguous buffers still, but this time only organised by 'tag'. There can be a tag for depth, material texture, whatever.
internal class NodeBank
{
    var idBank = NodeIDBank();
    var pathBank = NodePathBank();
    
    //////////////////
    // Node creation
    
    internal func CreateNode(components: Array<Component.Type>)
    {
        
    }
    
    internal func GetNode(id: NodeID) -> Node?
    {
        return nil;
    }
    
    internal func GetNode(id: NodePath) -> Node?
    {
        return nil;
    }
    

}

internal struct NodeArchetype
{
    // The component types that live in this archetype.
    internal var ComponentTypes = Dictionary<HashableType<Component>, Int>();
    internal var ComponentTypeArray = Array<HashableType<Component>>();
    internal var ArchetypeTags = Dictionary<String, String>();
    
    internal var Nodes = try! Buffer<Node>();
    internal var Components = ContiguousDictionary<HashableType<Component>,Buffer<Component>>();
}

internal struct NodeIDBank
{
    var counter: UInt32 = 0;
    var idPool: Array<NodeID> = Array<NodeID>();
    
    // Gets a nodeID (either new or reused).
    mutating func Pop() -> NodeID
    {
        let returnCounter = counter;
        
        if (idPool.count > 0)
        {
            let nodeID = idPool.removeLast();
            let reuseCounter = nodeID.reuseCounter + 1
            
            // If we keep reusing the same id rapidly, we might eventually max out the reuse counter...
            if(reuseCounter < UInt16.max)
            {
                // We can reuse this id.
                return NodeID(id: nodeID.id, reuseCounter: reuseCounter);
            }
        }
        
        counter += 1;
        return NodeID(id: returnCounter, reuseCounter: 0);
    }
    
    // Push an unused nodeID in here so it gets reused when we next create a node.
    mutating func Push(nodeID: NodeID)
    {
        idPool.append(nodeID);
    }
}

internal struct NodePathBank
{
    // Note that there's a trick in the hashing function of NodeID that means that nodeIDs hash just the raw id.
    var pathBank = ContiguousDictionary<NodeID,NodePath>();
    
    subscript(nodeID: NodeID) -> NodePath
    {
        get
        {
            let nodeID = pathBank[nodeID];
            assert(nodeID != nil, "The node you're requesting a path for doesn't exist!");
            return nodeID!;
        }
    }
    
    mutating func AddNode(nodeID: NodeID, nodePath: NodePath)
    {
        let index = pathBank.GetIndexForKey(nodeID);
        if( index == -1)
        {
            pathBank[nodeID] = nodePath;
            return;
        }
        
        assertionFailure("Tried to add a new nodepath when one already exists! Update instead.");
    }
    
    mutating func UpdatePath(nodeID: NodeID, nodePath: NodePath)
    {
        let index = pathBank.GetIndexForKey(nodeID);

        if( index != -1)
        {
            let internalNodeID = pathBank.GetKey(UInt(index))!;
            
            if(internalNodeID.reuseCounter < nodeID.reuseCounter )
            {
                pathBank[nodeID] = nodePath;
                return;
            }
            assertionFailure("The node you're trying to update is newer than the ID you're supplying.");
            return;
        }
        
        assertionFailure("Tried to update a nodepath when it doesn't exist! Add instead.");
    }
    
    mutating func RemoveNode(nodeID: NodeID)
    {
        let index = pathBank.GetIndexForKey(nodeID);

        if( index != -1)
        {
            pathBank.RemoveKey(nodeID);
            return;
        }
        assertionFailure("Trying to remove a node path when none is associated with that index!");
    }
    
    
}

/* Tree structure of all the possible permutations of component types. Used to attempt to minimise the amount of archetype fragmentation by nodes that mutate a lot. Given a soup of types (including duplicate types), by trawling through this structure, one can determine a preferred sort order for these types.*/
class NodeComponentOrderTree
{
    class NodeComponentOrderBranch
    {
        var Types = Array<HashableType<Component>>();
        var Branches = Array<NodeComponentOrderBranch>();
    }
    
    let Root = NodeComponentOrderBranch();
    
    // Returns the ideal order for the given components, or stores a new ideal order if the given component block is unknown.
    func GetOrderedArrayFromUnorderedComponentArray(_ unorderedComponentArray: Array<HashableType<Component>>) -> Array<HashableType<Component>>
    {
        var localUnorderedComponentArray = unorderedComponentArray;
        var currentBranch: NodeComponentOrderBranch? = Root;
        
        var returnArray = Array<HashableType<Component>>();
        
        if(unorderedComponentArray.count > 0)
        {
            while (currentBranch != nil)
            {
                var found = false;
                for elementIndex in 0...currentBranch!.Types.count
                {
                    for testElementIndex in 0...localUnorderedComponentArray.count
                    {
                        let testElement = localUnorderedComponentArray[testElementIndex];
                        if( currentBranch!.Types[elementIndex] == testElement )
                        {
                            returnArray.append(currentBranch!.Types[elementIndex]);
                            localUnorderedComponentArray.remove(at: testElementIndex);
                            
                            if(localUnorderedComponentArray.count > 0)
                            {
                                currentBranch = currentBranch!.Branches[elementIndex];
                            }
                            else
                            {
                                currentBranch = nil;
                            }
                            
                            found = true;
                            break;
                        }
                    }
                    
                    if(found)
                    {
                        break;
                    }
                }
                
                // None of the elements in the branch matched the unordered array, dump out the rest of the values for now...
                if(!found)
                {
                    for element in localUnorderedComponentArray
                    {
                        let newBranch = NodeComponentOrderBranch();
                        returnArray.append(element);
                        currentBranch!.Types.append(element);
                        currentBranch!.Branches.append(newBranch);
                        currentBranch = newBranch;
                    }
                    
                    currentBranch = nil;
                }
            }
        }
        
        return returnArray;
    }
}
