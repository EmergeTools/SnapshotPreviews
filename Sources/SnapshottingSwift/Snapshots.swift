//
//  File.swift
//  
//
//  Created by Noah Martin on 7/12/23.
//

import Foundation
import SnapshotPreviewsCore
import SwiftUI
import UIKit
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
  let server = HTTPServer(port: 8080)

  public init() {
    let windowScene = UIApplication.shared
      .connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .first

    let window = UIWindow(windowScene: windowScene as! UIWindowScene)
    window.windowLevel = .statusBar + 1
    window.backgroundColor = UIColor.systemBackground
    window.makeKeyAndVisible()
    self.window = window
    
    Task {
      try await startServer()
    }
  }

  let window: UIWindow

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
      let (imageResult, preview) = await self.display(typeName: typeName, id: id)

      if let displayName = preview.displayName {
        result["displayName"] = displayName
      }

      let fileName = Self.fileName(typeName: typeName, previewId: id)
      let file = Self.resultsDir.appendingPathComponent(fileName, isDirectory: false)
      do {
        let image = try imageResult.get()
        if let pngData = image.pngData() {
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
      return HTTPResponse(statusCode: .ok, body: Self.resultsDir.path.data(using: .utf8)!)
    }

    try await server.start()
  }

  @MainActor func display(typeName: String, id: String) async -> (Result<UIImage, Error>, SnapshotPreviewsCore.Preview) {
    let previewTypes = findPreviews { name in
      return name == typeName
    }

    let provider = previewTypes[0]
    let preview = provider.previews.filter { $0.previewId == id }[0]
    return (try! await display(preview: preview), preview)
  }

  @MainActor func display(preview: SnapshotPreviewsCore.Preview) async throws -> Result<UIImage, Error> {
    var view = try preview.view()
    let supportsExpansion = ViewInspection.shouldExpand(view)
    let renderingMode = ViewInspection.renderingMode(of: view)
    if let colorScheme = try preview.colorScheme() {
      view = AnyView(view.colorScheme(colorScheme))
    }
      
    return await withCheckedContinuation({ (continuation: CheckedContinuation<Result<UIImage, Error>, Never>) in
      view.snapshot(
        layout: preview.layout,
        window: window,
        supportsExpansion: supportsExpansion,
        renderingMode: renderingMode,
        async: false) { result in
          continuation.resume(returning: result)
        }
    })
  }

  @MainActor func writeClassNames() {
    try? FileManager.default.removeItem(at: Self.resultsDir)
    try! FileManager.default.createDirectory(at: Self.resultsDir, withIntermediateDirectories: true)

    let snapshotPreviews = ProcessInfo.processInfo.environment["SNAPSHOT_PREVIEWS"];
    var previewsSet: Set<String>? = nil
    if let snapshotPreviews {
      let previewsList = try! JSONDecoder().decode([String].self, from: snapshotPreviews.data(using: .utf8)!)
      previewsSet = Set(previewsList)
    }
    let previewTypes = findPreviews { name in
      guard let previewsSet else { return true }

      return previewsSet.contains(name)
    }
    let json = previewTypes.map { preview in
      [
        "typeName": preview.typeName,
        "numPreviews": preview.previews.count,
      ]
    }
    let data = try! JSONSerialization.data(withJSONObject: json)
    try! data.write(to: Self.resultsDir.appendingPathComponent("metadata.json", isDirectory: false))
  }

  private static func fileName(typeName: String, previewId: String) -> String {
    "\(typeName)-\(previewId).png"
  }
}
