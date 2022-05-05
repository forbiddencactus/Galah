
struct NodeArchetypeHelpers
{
    static func GetArchetypeTags(nodeData: NodeData, components: Array<Component>) -> Array<ArchetypeTagKeyValuePair>
    {
        var returnArray = Array<ArchetypeTagKeyValuePair>();
        returnArray.append(ArchetypeTagKeyValuePair(key: NodeArchetypeTag.NodeDepth, value: String(nodeData.Depth)));
        
        for component in components
        {
            returnArray.append(contentsOf: component.GetArchetypeTags());
        }
        
        return returnArray;
    }

}
