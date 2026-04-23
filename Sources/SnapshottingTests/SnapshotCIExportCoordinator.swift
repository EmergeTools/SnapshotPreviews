//
//  SnapshotCIExportCoordinator.swift
//  SnapshottingTests
//
//  Manages CI export of snapshot PNGs and JSON sidecar metadata
//  directly to the filesystem when SNAPSHOTS_EXPORT_DIR is set.
//

import Foundation
import XCTest
@_implementationOnly import SnapshotPreviewsCore

// MARK: - Snapshot Context

struct SnapshotContext: Sendable {
  let baseFileName: String
  let testName: String
  let typeName: String
  let typeDisplayName: String
  let fileId: String?
  let line: Int?
  let previewDisplayName: String?
  let previewIndex: Int
  let orientation: String
  let simulatorDeviceName: String?
  let simulatorModelIdentifier: String?
  let diffThreshold: Float?
  let accessibilityEnabled: Bool?
  let colorScheme: String?
}

// MARK: - Sidecar Model

private struct SnapshotSidecar: Sendable, Encodable {
  let displayName: String
  let group: String
  let tags: Tags?
  let diffThreshold: Float?
  let context: Context

  struct Tags: Sendable, Encodable {
    let orientation: String?
    let device: String?
  }

  struct Context: Sendable, Encodable {
    let testName: String
    let accessibilityEnabled: Bool
    let preferredColorScheme: String?
    let simulator: Simulator?
    let preview: Preview

    struct Simulator: Sendable, Encodable {
      let deviceName: String?
      let modelIdentifier: String?
    }
    
    struct Preview: Sendable, Encodable {
      let index: Int
      /// The author-declared `.previewDisplayName(...)` value, if set.
      let displayName: String?
      /// Fully-qualified type name of the container that declared this preview
      /// (the `PreviewProvider` struct, or the compiler-synthesized `PreviewRegistry`
      /// conformance for a `#Preview` macro).
      let containerTypeName: String
      /// Human-readable label derived from the container's type name or file name.
      /// Not author-declared — there's no SwiftUI API to set it.
      let containerDisplayName: String
      let line: Int?
    }
  }

  init(
    context: SnapshotContext,
    imageFileName: String,
    displayName: String,
    group: String
  ) {
    self.displayName = displayName
    self.group = group
    self.diffThreshold = context.diffThreshold

    let orientation = context.orientation.isEmpty ? nil : context.orientation
    let device = context.simulatorDeviceName.flatMap { $0.isEmpty ? nil : $0 }
    self.tags = (orientation == nil && device == nil)
      ? nil
      : Tags(orientation: orientation, device: device)

    let simulator: Context.Simulator? =
      (context.simulatorDeviceName == nil && context.simulatorModelIdentifier == nil)
      ? nil
      : Context.Simulator(
          deviceName: context.simulatorDeviceName,
          modelIdentifier: context.simulatorModelIdentifier
        )

    self.context = Context(
      testName: context.testName,
      accessibilityEnabled: context.accessibilityEnabled ?? false,
      preferredColorScheme: context.colorScheme,
      simulator: simulator,
      preview: Context.Preview(
        index: context.previewIndex,
        displayName: context.previewDisplayName,
        containerTypeName: context.typeName,
        containerDisplayName: context.typeDisplayName,
        line: context.line
      )
    )
  }
}

// MARK: - Coordinator

final class SnapshotCIExportCoordinator: NSObject, XCTestObservation {

  static let envKey = "SNAPSHOTS_EXPORT_DIR"

  static func diffThreshold(for precision: Float?) -> Float? {
    precision.map { 1 - $0 }
  }

  private let exportDirectoryURL: URL
  private let writeQueue: OperationQueue
  private let fileManager: FileManager
  private let stateLock = NSLock()
  private var hasDrained = false

  // MARK: - Factory

  static func createFromEnvironment(
    environment: [String: String] = ProcessInfo.processInfo.environment
  ) -> SnapshotCIExportCoordinator? {
    guard let exportDir = environment[envKey] else {
      return nil
    }

    let trimmed = exportDir.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      preconditionFailure(
        "\(envKey) is set but empty. Provide a valid directory path."
      )
    }

    let url: URL
    if trimmed.hasPrefix("/") {
      url = URL(fileURLWithPath: trimmed, isDirectory: true).standardizedFileURL
    } else {
      url = URL(
        fileURLWithPath: FileManager.default.currentDirectoryPath,
        isDirectory: true
      )
      .appendingPathComponent(trimmed, isDirectory: true)
      .standardizedFileURL
    }

    let coordinator = Self(exportDirectoryURL: url)
    XCTestObservationCenter.shared.addTestObserver(coordinator)
    return coordinator
  }

  // MARK: - Init

  init(
    exportDirectoryURL: URL,
    fileManager: FileManager = .default,
    writeQueue: OperationQueue = .defaultQueue
  ) {
    self.exportDirectoryURL = exportDirectoryURL
    self.fileManager = fileManager
    self.writeQueue = writeQueue

    super.init()

    do {
      try self.fileManager.createDirectory(
        at: exportDirectoryURL,
        withIntermediateDirectories: true
      )
    } catch {
      preconditionFailure(
        "Failed to create snapshot export directory at \(exportDirectoryURL.path): \(error)"
      )
    }
  }

  // MARK: - Filename Sanitization

  static func sanitize(_ raw: String) -> String {
    var result = ""
    var lastWasUnderscore = false

    for c in raw {
      if c.isLetter || c.isNumber || c == "." || c == "-" || c == "_" {
        result.append(c)
        lastWasUnderscore = false
      } else if !lastWasUnderscore {
        result.append("_")
        lastWasUnderscore = true
      }
    }

    result = result.trimmingCharacters(in: CharacterSet(charactersIn: "_.-"))

    return result.isEmpty ? "snapshot" : result
  }

  // MARK: - Export

  static func canonicalGroup(
    fileId: String?,
    typeDisplayName: String,
    typeName: String
  ) -> String {
    if let fileId, !fileId.isEmpty {
      return fileId
    }

    if !typeDisplayName.isEmpty {
      return typeDisplayName
    }

    return typeName
  }

  static func canonicalGroup(for previewType: SnapshotPreviewsCore.PreviewType) -> String {
    canonicalGroup(
      fileId: previewType.fileID,
      typeDisplayName: previewType.displayName,
      typeName: previewType.typeName
    )
  }

  private static func canonicalDisplayName(for context: SnapshotContext) -> String {
    if let previewDisplayName = context.previewDisplayName, !previewDisplayName.isEmpty {
      return previewDisplayName
    }

    if context.fileId != nil, let line = context.line {
      return "At line #\(line)"
    }

    return String(context.previewIndex)
  }

  /// Enqueues a snapshot export (PNG + JSON sidecar) to the export directory.
  ///
  /// PNG encoding and file writes are dispatched to a concurrent background queue
  /// so the calling test can proceed to the next preview immediately.
  func enqueueExport(
    result: SnapshotResult,
    context: SnapshotContext
  ) {
    let pngFileName = "\(context.baseFileName).png"
    let jsonFileName = "\(context.baseFileName).json"

    let displayName = Self.canonicalDisplayName(for: context)
    let group = Self.canonicalGroup(
      fileId: context.fileId,
      typeDisplayName: context.typeDisplayName,
      typeName: context.typeName
    )
    let exportDir = exportDirectoryURL
    
    guard case .success(let image) = result.image else { return }
    
    writeQueue.addOperation {
      let pngURL = exportDir.appendingPathComponent(pngFileName)
      guard let pngData = image.emg.pngData() else {
        NSLog("[SnapshotCIExport] Failed to encode PNG for %@", pngFileName)
        return
      }
      do {
        try pngData.write(to: pngURL, options: .atomic)
      } catch {
        NSLog("[SnapshotCIExport] Failed to write PNG %@: %@", pngFileName, "\(error)")
        return
      }

      let sidecar = SnapshotSidecar(
        context: context,
        imageFileName: context.baseFileName,
        displayName: displayName,
        group: group
      )

      let jsonURL = exportDir.appendingPathComponent(jsonFileName)
      do {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(sidecar)
        try data.write(to: jsonURL, options: .atomic)
      } catch {
        NSLog("[SnapshotCIExport] Failed to write sidecar %@: %@", jsonFileName, "\(error)")
      }
    }
  }

  // MARK: - Drain

  /// Waits for all queued PNG and sidecar writes to complete.
  ///
  /// Called automatically via `testBundleDidFinish`. Safe to call multiple times —
  /// only the first call performs the drain.
  func drain() {
    stateLock.lock()
    guard !hasDrained else {
      stateLock.unlock()
      return
    }
    hasDrained = true
    stateLock.unlock()

    writeQueue.waitUntilAllOperationsAreFinished()
  }

  // MARK: - XCTestObservation

  func testBundleDidFinish(_ testBundle: Bundle) {
    drain()
  }
}

private extension OperationQueue {
  static var defaultQueue: OperationQueue {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 20
    queue.qualityOfService = .userInitiated
    return queue
  }
}
