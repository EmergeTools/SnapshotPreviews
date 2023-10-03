//
//  MetadataTypes.swift
//
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/Metadata.h#L2472-L2643
struct ProtocolConformanceDescriptor {
  let protocolDescriptor: Int32
  var nominalTypeDescriptor: Int32
  let protocolWitnessTable: Int32
  let conformanceFlags: ConformanceFlags
}

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/Metadata.h#L3139-L3222
struct ProtocolDescriptor {
  let flags: UInt32
  let parent: Int32
  let name: Int32
  let numRequirementsInSignature: UInt32
  let numRequirements: UInt32
  let associatedTypeNames: Int32
}

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L1203-L1234
public enum ContextDescriptorKind: UInt8 {
  case Module = 0
  case Extension = 1
  case Anonymous = 2
  case `Protocol` = 3
  case OpaqueType = 4
  case Class = 16
  case Struct = 17
  case Enum = 18
}

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L1237-L1312
struct ContextDescriptorFlags {

  private let rawFlags: UInt32

  var kind: ContextDescriptorKind? {
    let value = UInt8(rawFlags & 0x1F)
    return ContextDescriptorKind(rawValue: value)
  }
}

struct TargetModuleContextDescriptor {
  let flags: ContextDescriptorFlags
  let parent: Int32
  let name: Int32
  let accessFunction: Int32
}

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L372-L398
enum TypeReferenceKind: UInt32 {
  case DirectTypeDescriptor = 0
  case IndirectTypeDescriptor = 1
  case DirectObjCClassName = 2
  case IndirectObjCClass = 3
}

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L582-L687
struct ConformanceFlags {

  private let rawFlags: UInt32

  var kind: TypeReferenceKind? {
    let rawKind = (rawFlags & Self.TypeMetadataKindMask) >> Self.TypeMetadataKindShift
    return TypeReferenceKind(rawValue: rawKind)
  }

  private static let TypeMetadataKindMask: UInt32 = 0x7 << Self.TypeMetadataKindShift
  private static let TypeMetadataKindShift = 3
}
