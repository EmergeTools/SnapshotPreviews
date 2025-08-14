//
//  ConformanceLookup.swift
//
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import MachO

private func getTypeName(descriptor: UnsafePointer<TargetModuleContextDescriptor>) -> String? {
  let flags = descriptor.pointee.flags
  var parentName: String? = nil
  if descriptor.pointee.parent != 0 {
    let parent = UnsafeRawPointer(descriptor).advanced(by: MemoryLayout<TargetModuleContextDescriptor>.offset(of: \.parent)!).advanced(by: Int(descriptor.pointee.parent))
    if abs(descriptor.pointee.parent) % 2 == 1 {
      return nil
    }
    parentName = getTypeName(descriptor: parent.assumingMemoryBound(to: TargetModuleContextDescriptor.self))
  }
  switch flags.kind {
  case .Module, .Enum, .Struct, .Class:
    let name = UnsafeRawPointer(descriptor)
      .advanced(by: MemoryLayout<TargetModuleContextDescriptor>.offset(of: \.name)!)
      .advanced(by: Int(descriptor.pointee.name))
      .assumingMemoryBound(to: CChar.self)
    let typeName = String(cString: name)
    if let parentName = parentName {
      return "\(parentName).\(typeName)"
    }
    return typeName
  default:
    return parentName
  }
}

public typealias LookupResult = (name: String, accessor: () -> UInt64, proto: String)

private func parseConformance(conformance: UnsafePointer<ProtocolConformanceDescriptor>) -> LookupResult? {
  let flags = conformance.pointee.conformanceFlags

  guard case .DirectTypeDescriptor = flags.kind else {
    return nil
  }

  guard conformance.pointee.protocolDescriptor % 2 == 1 else {
    return nil
  }
  let descriptorOffset = Int(conformance.pointee.protocolDescriptor & ~1)
  let jumpPtr = UnsafeRawPointer(conformance).advanced(by: MemoryLayout<ProtocolConformanceDescriptor>.offset(of: \.protocolDescriptor)!).advanced(by: descriptorOffset)
  let address = jumpPtr.load(as: UInt64.self)

  // Address will be 0 if the protocol is not available (such as only defined on a newer OS)
  guard address != 0 else {
    return nil
  }
  let protoPtr = UnsafeRawPointer(bitPattern: UInt(address))!
  let proto = protoPtr.load(as: ProtocolDescriptor.self)
  let namePtr = protoPtr.advanced(by: MemoryLayout<ProtocolDescriptor>.offset(of: \.name)!).advanced(by: Int(proto.name))
  let protocolName = String(cString: namePtr.assumingMemoryBound(to: CChar.self))
  guard ["PreviewProvider", "PreviewRegistry"].contains(protocolName) else {
    return nil
  }

  let typeDescriptorPointer = UnsafeRawPointer(conformance).advanced(by: MemoryLayout<ProtocolConformanceDescriptor>.offset(of: \.nominalTypeDescriptor)!).advanced(by: Int(conformance.pointee.nominalTypeDescriptor))

  let descriptor = typeDescriptorPointer.assumingMemoryBound(to: TargetModuleContextDescriptor.self)
  if let name = getTypeName(descriptor: descriptor),
     [ContextDescriptorKind.Class, ContextDescriptorKind.Struct, ContextDescriptorKind.Enum].contains(descriptor.pointee.flags.kind) {
    let accessFunctionPointer = UnsafeRawPointer(descriptor).advanced(by: MemoryLayout<TargetModuleContextDescriptor>.offset(of: \.accessFunction)!).advanced(by: Int(descriptor.pointee.accessFunction))
    let accessFunction = unsafeBitCast(accessFunctionPointer, to: (@convention(c) () -> UInt64).self)
    return (name, accessFunction, protocolName)
  }
  return nil
}

#if arch(i386) || arch(arm) || arch(arm64_32)
typealias mach_header_type = mach_header
#else
typealias mach_header_type = mach_header_64
#endif

public func getPreviewTypes() -> [LookupResult] {
  let images = _dyld_image_count()
  var types = [LookupResult]()
  for i in 0..<images {
    let header = _dyld_get_image_header(i)!
    let headerType = UnsafeRawPointer(header).assumingMemoryBound(to: mach_header_type.self)

    // Anything in the dylib cache is a system library that we should not include
    guard headerType.pointee.flags & MH_DYLIB_IN_CACHE == 0 else {
      continue
    }

    let imageName = String(cString: _dyld_get_image_name(i))
    guard !imageName.contains(".simruntime") && !imageName.contains(".platform") && !imageName.starts(with: "/usr/lib/") && !imageName.starts(with: "/System/Library/") else {
      continue
    }

    var size: UInt = 0
    let sectStart = UnsafeRawPointer(
      getsectiondata(
        headerType,
        "__TEXT",
        "__swift5_proto",
        &size))?.assumingMemoryBound(to: Int32.self)
    if var sectData = sectStart {
      for _ in 0..<Int(size)/MemoryLayout<Int32>.size {
        let conformance = UnsafeRawPointer(sectData)
          .advanced(by: Int(sectData.pointee))
          .assumingMemoryBound(to: ProtocolConformanceDescriptor.self)
        if let result = parseConformance(conformance: conformance) {
          types.append(result)
        }
        sectData = sectData.successor()
      }
    }
  }
  return types
}
