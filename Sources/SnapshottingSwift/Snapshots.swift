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

  public init() {
    #if canImport(UIKit) && !os(watchOS) && !os(visionOS) && !os(tvOS)
    renderingStrategy = UIKitRenderingStrategy()
    #elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
    renderingStrategy = AppKitRenderingStrategy()
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
    let previewTypes = FindPreviews.findPreviews { name, _ in
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

  @MainActor static func writeClassNames() {
    try? FileManager.default.removeItem(at: Self.resultsDir)
    try! FileManager.default.createDirectory(at: Self.resultsDir, withIntermediateDirectories: true)

    let snapshotPreviews = ProcessInfo.processInfo.environment["SNAPSHOT_PREVIEWS"].map { try! JSONDecoder().decode([String].self, from: $0.data(using: .utf8)!) }
    let excludedSnapshotPreviews = ProcessInfo.processInfo.environment["EXCLUDED_SNAPSHOT_PREVIEWS"].map { try! JSONDecoder().decode([String].self, from: $0.data(using: .utf8)!) }

    let previewTypes = FindPreviews.findPreviews(included: snapshotPreviews, excluded: excludedSnapshotPreviews)

    let json = previewTypes.map { preview -> [String: Any]? in
      var data = [
        "typeName": preview.typeName,
        "numPreviews": preview.previews.count,
        "devices": preview.previews.map { $0.device?.rawValue ?? ""},
        "orientations": preview.previews.map { $0.orientation.id }
      ]
      if let fileId = preview.fileID, #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
        var name = fileId
        if let displayName = preview.previews[0].displayName {
          name = "\(fileId):\(displayName)"
        }
        data["displayName"] = name
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
