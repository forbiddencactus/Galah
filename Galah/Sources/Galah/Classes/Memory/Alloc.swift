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
// Placement new allocators and other things for manual memory management.

/*
 Special thanks to these websites for helping me comprehend Swift's runtime:
 https://kateinoigakukun.hatenablog.com/entry/2019/03/22/184356
 https://belkadan.com/blog/2020/08/Swift-Runtime-Heap-Objects/
 https://cdmana.com/2021/02/20210214042606386H.html
 https://github.com/wickwirew/Runtime
 */
// Cheers to Wes Wickwire for their awesome work opening up the Swift runtime! Functional swift here we come!

import GalahNative.SwiftRuntime;

internal func galah_placementNew<T>(_ ptr: Ptr<T>) throws -> T where T: AnyObject
{
    return try galah_placementNew(type: T.self, ptr: Cast(ptr)) as! T;
}

internal func galah_placementNew(type: Any.Type, ptr: VoidPtr) throws -> AnyObject
{
    var md = ClassMetadata(type: type.self);
    let info = md.toTypeInfo();
    let metadata = unsafeBitCast(type.self, to: UnsafeRawPointer.self);

    let value: UnsafeMutableRawPointer = ptr;

    value.storeBytes(of: metadata, as: UnsafeRawPointer.self);
    try setProperties(typeInfo: info, pointer: UnsafeMutableRawPointer(mutating: value));

    return unsafeBitCast(value, to: AnyObject.self);
}

// Returns a tuple pointing to a type's value witness table & metadata.
internal func galah_getValueWitnessTable(type: Any.Type) -> (Ptr<ValueWitnessTable>?,VoidPtr?)
{
    let kind = Kind(type: type)
    
    var metadataPtr: VoidPtr? = nil;
    var valueWitnessPtr: Ptr<ValueWitnessTable>? = nil;
    switch kind
    {
        case .struct:
            let meta = StructMetadata(type: type);
            metadataPtr = Cast(meta.pointer);
            valueWitnessPtr = meta.valueWitnessTable;
            break;
        case .class:
            let meta = ClassMetadata(type: type);
            metadataPtr = Cast(meta.pointer);
            valueWitnessPtr = meta.valueWitnessTable;
            break;
        case .existential:
            let meta = ProtocolMetadata(type: type);
            metadataPtr = Cast(meta.pointer);
            valueWitnessPtr = meta.valueWitnessTable;
            break;
        case .tuple:
            let meta = TupleMetadata(type: type);
            metadataPtr = Cast(meta.pointer);
            valueWitnessPtr = meta.valueWitnessTable;
            break;
        case .enum:
            let meta = EnumMetadata(type: type);
            metadataPtr = Cast(meta.pointer);
            valueWitnessPtr = meta.valueWitnessTable;
            break;
        default:
            assertionFailure("Unknown type.");
    }
    
    return (valueWitnessPtr, metadataPtr);
}

// Copies a value into the specified pointer, this means the ref counter will increase the ref count of any refs contained in the value.
internal func galah_copyValue(dest: VoidPtr, source: VoidPtr, type: Any.Type)
{
    let valueWitness = galah_getValueWitnessTable(type: type);
    _ = valueWitness.0!.pointee.assignWithCopy(dest, source, valueWitness.1!);
}

// Copies a value from the specified (unmanaged) pointer, this means the ref counter will decrease the ref count of any refs contained in the value.
internal func galah_takeValue(dest: VoidPtr, source: VoidPtr, type: Any.Type)
{
    let valueWitness = galah_getValueWitnessTable(type: type);
    _ = valueWitness.0!.pointee.assignWithCopy(dest, source, valueWitness.1!);
}

internal func galah_runDestructor(obj: AnyObject)
{
    let md = ClassMetadata(type: type(of: obj));

    let rawObjectRef = unsafeBitCast(obj, to: UnsafeMutableRawPointer.self);
    let rawDestructor = unsafeBitCast(md.destructor, to: UnsafeMutablePointer<UnsafeMutableRawPointer?>?.self);
    
    glh_runSwiftDestructor(rawDestructor, rawObjectRef);
}
