
struct NodeArchetypeHelpers
{
    static func GetArchetypeTags(depth: UInt, components: Array<Component>) -> Array<ArchetypeTagKeyValuePair>
    {
        var returnArray = Array<ArchetypeTagKeyValuePair>();
        returnArray.append(ArchetypeTagKeyValuePair(key: NodeArchetypeTag.NodeDepth, value: String(depth)));
        
        for component in components
        {
            returnArray.append(contentsOf: component.GetArchetypeTags());
        }
        
        return returnArray;
    }

}
