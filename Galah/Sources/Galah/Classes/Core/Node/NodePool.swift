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

// Unique id for a node. Packed into a convenient word sized package!
internal struct NodeID
{
    internal let id: UInt32;
    internal let reuseCounter: UInt16; // The number of times this index has been reused.
    internal let componentIndex: UInt8; // The index of the component we're pointing to, if we're pointing to one. Otherwise, 0.
    internal let metadata: UInt8; // ??? 8 bits of empty space for whatever.
    
    init()
    {
        id = UInt32.max;
        componentIndex = UInt8.max;
        reuseCounter = UInt16.max;
        metadata = UInt8.max;
    }
}

// Path to the memory location of a node, or component.
internal struct NodePath
{
    internal var instanceIndex: UInt32; // The index of the instance, inside the buffer.
    internal var archetypeIndex: UInt16; // Which archetype this instance belongs to.
    internal var componentIndex: UInt16; // The index of the component, if we're pointing to one.
    
    init()
    {
        // Invalid indices always have their values maxed out.
        archetypeIndex = UInt16.max;
        instanceIndex = UInt32.max;
        componentIndex = UInt16.max;
    }
    
    func IsValid() -> Bool
    {
        if(componentIndex == UInt16.max || archetypeIndex == UInt16.max || instanceIndex == UInt32.max)
        {
            return false;
        }
        
        return true;
    }
}

// Tree structure of all the possible permutations of component types. Used to attempt to minimise the amount of archetype fragmentation by nodes that mutate a lot.
// Given a soup of types (including duplicate types), by trawling through this structure, one can determine a preferred sort order for these types.
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

public protocol NodePoolObject: AnyObject {}

internal struct NodeArchetype
{
    // The component types that live in this archetype. 
    internal var ComponentTypes = Dictionary<HashableType<Component>, Int>();
    internal var ComponentTypeArray = Array<HashableType<Component>>();
    internal var ArchetypeTags = Dictionary<String, String>();
    
    internal var Nodes = try! Buffer<Node>();
    //internal var Components = ContiguousDictionary<HashableType<Component>,Buffer<Component>>();
}

// NEW IDEA: contiguous buffers still, but this time only organised by 'tag'. There can be a tag for depth, material texture, whatever.
internal class NodePool
{
    internal func GetNode(id: NodeID) -> Node?
    {
        return nil;
    }
    
    internal func GetNode(id: NodePath) -> Node?
    {
        return nil;
    }
    

}
