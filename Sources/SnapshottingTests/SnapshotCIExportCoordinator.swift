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

struct SnapshotContext: Sendable, Encodable {
  let baseFileName: String
  let testName: String
  let typeName: String
  let typeDisplayName: String
  let fileId: String?
  let line: Int?
  let previewDisplayName: String?
  let previewIndex: Int
  let previewId: String
  let orientation: String
  let declaredDevice: String?
  let simulatorDeviceName: String?
  let simulatorModelIdentifier: String?
  let precision: Float?
  let accessibilityEnabled: Bool?
  let colorScheme: String?
  let appStoreSnapshot: Bool?
}

// MARK: - Sidecar Model

private struct SnapshotCIExportSidecar: Sendable, Encodable {
  let context: SnapshotContext
  let imageFileName: String
  let displayName: String
  let group: String

  private enum ExtraKeys: String, CodingKey {
    case image_file_name
    case display_name
    case group
  }

  func encode(to encoder: Encoder) throws {
    try context.encode(to: encoder)
    var container = encoder.container(keyedBy: ExtraKeys.self)
    try container.encode(imageFileName, forKey: .image_file_name)
    try container.encode(displayName, forKey: .display_name)
    try container.encode(group, forKey: .group)
  }
}

// MARK: - Coordinator

final class SnapshotCIExportCoordinator: NSObject, XCTestObservation {

  static let envKey = "SNAPSHOTS_EXPORT_DIR"

  private let exportDirectoryURL: URL
  private let writeQueue: OperationQueue
  private let fileManager: FileManager
  private let stateLock = NSLock()
  private var hasDrained = false

  // MARK: - Shared Instance

  @MainActor private static var _shared: SnapshotCIExportCoordinator?

  @MainActor static func sharedIfEnabled(
    environment: [String: String] = ProcessInfo.processInfo.environment
  ) -> SnapshotCIExportCoordinator? {
    if let _shared { return _shared }

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
    _shared = coordinator
    XCTestObservationCenter.shared.addTestObserver(coordinator)
    return coordinator
  }

  /// Resets shared state. Exposed for testing only.
  @MainActor static func resetShared() {
    if let shared = _shared {
      XCTestObservationCenter.shared.removeTestObserver(shared)
    }
    _shared = nil
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

  private static func canonicalGroup(for context: SnapshotContext) -> String {
    if let fileId = context.fileId, !fileId.isEmpty {
      return fileId
    }

    if !context.typeDisplayName.isEmpty {
      return context.typeDisplayName
    }

    return context.typeName
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
    let sanitizedName = Self.sanitize(context.baseFileName)
    let pngFileName = "\(sanitizedName).png"
    let jsonFileName = "\(sanitizedName).json"

    let displayName = Self.canonicalDisplayName(for: context)
    let group = Self.canonicalGroup(for: context)
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

      let sidecar = SnapshotCIExportSidecar(
        context: context,
        imageFileName: sanitizedName,
        displayName: displayName,
        group: group
      )

      let jsonURL = exportDir.appendingPathComponent(jsonFileName)
      do {
        let encoder = JSONEncoder()
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

    guard fileManager.fileExists(atPath: exportDirectoryURL.path) else { return }

    let semaphore = DispatchSemaphore(value: 0)
    writeQueue.addBarrierBlock {
      semaphore.signal()
    }
    semaphore.wait()
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
