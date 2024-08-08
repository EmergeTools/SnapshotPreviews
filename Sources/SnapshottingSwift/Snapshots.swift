//
//  File.swift
//  
//
//  Created by Noah Martin on 7/12/23.
//

import Foundation
import SnapshotPreviewsCore
import SwiftUI
import FlyingFox

enum SnapshotError: Error {
  case pngData
}

extension SnapshotError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .pngData:
      return "Error converting image to png"
    }
  }
}

class Snapshots {
  let server = HTTPServer(address: .loopback(port: 38824))
  let testHandler: NSObject.Type? = NSClassFromString("EMGTestHandler") as? NSObject.Type

  public init() {
    #if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
    renderingStrategy = UIKitRenderingStrategy()
    #else
    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
      renderingStrategy = SwiftUIRenderingStrategy()
    } else {
      preconditionFailure("Cannot snapshot on this device/os")
    }
    #endif
    Task {
      try await startServer()
    }
  }

  let renderingStrategy: RenderingStrategy

  var previews: [(SnapshotPreviewsCore.Preview, String)] = []

  var errors: [(preview: SnapshotPreviewsCore.Preview, typeName: String, error: Error)] = []

  var completion: (() -> Void)?

  static let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  static let resultsDir = documentsURL.appendingPathComponent("EMGSnapshots")

  func startServer() async throws {
    await server.appendRoute("GET /display/*") { [weak self] request in
      let pathComponents = request.path.components(separatedBy: "/")
      guard let self, pathComponents.count > 3 else {
        return HTTPResponse(statusCode: .badRequest)
      }

      let typeName = pathComponents[2]
      let id = pathComponents[3]

      var result: [String: String] = [:]
      testHandler?.perform(NSSelectorFromString("setup"))
      let (imageResult, preview) = await render(typeName: typeName, id: id)

      if let displayName = preview.displayName {
        result["displayName"] = displayName
      }

      let fileName = Self.fileName(typeName: typeName, previewId: id)
      try FileManager.default.createDirectory(at: Self.resultsDir, withIntermediateDirectories: true)
      let file = Self.resultsDir.appendingPathComponent(fileName, isDirectory: false)
      do {
        let image = try imageResult.get()
        if let pngData = image.emg.pngData() {
          try pngData.write(to: file)
          result["imagePath"] = file.path
        } else {
          print("Could not generate PNG data for \(file)")
          result["error"] = SnapshotError.pngData.localizedDescription
        }
      } catch {
        print("Failed to write \(file)")
        print(error)
        result["error"] = error.localizedDescription
      }

      return HTTPResponse(statusCode: .ok, body: try JSONEncoder().encode(result))
    }

    await server.appendRoute("GET /file") { request in
      await Self.writeClassNames()
      return HTTPResponse(statusCode: .ok, body: Self.resultsDir.path.data(using: .utf8)!)
    }

    try await server.start()
  }

  @MainActor func render(typeName: String, id: String) async -> (Result<ImageType, Error>, SnapshotPreviewsCore.Preview) {
    let previewTypes = findPreviews { name, _ in
      return name == typeName
    }

    let provider = previewTypes[0]
    let preview = provider.previews.filter { $0.previewId == id }[0]
    let result = await withCheckedContinuation { continuation in
      renderingStrategy.render(preview: preview) { result in
        continuation.resume(returning: result.image)
      }
    }
    return (result, preview)
  }

  @available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
  static func shouldInclude(name: String, excludedPreviewsSet: Set<String>?, previewsSet: Set<String>?) -> Bool {
    if let excludedPreviewsSet {
      for excludedPreview in excludedPreviewsSet {
        do {
          let regex = try Regex(excludedPreview)
          if name.firstMatch(of: regex) != nil {
            return false
          }
        } catch {
          print("Error trying to unwrap regex for excludedSnapshotPreview (\(excludedPreview)): \(error)")
        }
      }
    }

    guard let previewsSet else { return true }
    for preview in previewsSet {
      do {
        let regex = try Regex(preview)
        if name.firstMatch(of: regex) != nil {
          return true
        }
      } catch {
        print("Error trying to unwrap regex for snapshotPreview (\(preview)): \(error)")
      }
    }

    return false
  }

  @MainActor static func writeClassNames() {
    try? FileManager.default.removeItem(at: Self.resultsDir)
    try! FileManager.default.createDirectory(at: Self.resultsDir, withIntermediateDirectories: true)

    let snapshotPreviews = ProcessInfo.processInfo.environment["SNAPSHOT_PREVIEWS"];
    let excludedSnapshotPreviews = ProcessInfo.processInfo.environment["EXCLUDED_SNAPSHOT_PREVIEWS"];

    var previewsSet: Set<String>? = nil
    if let snapshotPreviews {
      let previewsList = try! JSONDecoder().decode([String].self, from: snapshotPreviews.data(using: .utf8)!)
      previewsSet = Set(previewsList)
    }
    var excludedPreviewsSet: Set<String>? = nil
    if let excludedSnapshotPreviews {
      let excludedPreviewsList = try! JSONDecoder().decode([String].self, from: excludedSnapshotPreviews.data(using: .utf8)!)
      excludedPreviewsSet = Set(excludedPreviewsList)
    }

    let previewTypes = findPreviews { name, proto in
      guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) else { return true }
      guard proto == "PreviewProvider" else { return true }

      return shouldInclude(name: name, excludedPreviewsSet: excludedPreviewsSet, previewsSet: previewsSet)
    }
    let json = previewTypes.compactMap { preview -> [String: Any]? in
      var data = [
        "typeName": preview.typeName,
        "numPreviews": preview.previews.count,
      ]
      if let fileId = preview.fileID, #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
        var name = fileId
        if let displayName = preview.previews[0].displayName {
          name = "\(fileId):\(displayName)"
        }
        data["displayName"] = name
        if !shouldInclude(name: name, excludedPreviewsSet: excludedPreviewsSet, previewsSet: previewsSet) {
          return nil
        }
      }

      return data
    }
    let data = try! JSONSerialization.data(withJSONObject: json)
    try! data.write(to: Self.resultsDir.appendingPathComponent("metadata.json", isDirectory: false))
  }

  private static func fileName(typeName: String, previewId: String) -> String {
    "\(typeName)-\(previewId).png"
  }
}
