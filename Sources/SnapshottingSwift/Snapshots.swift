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
  let testHandler: NSObject.Type? = NSClassFromString("EMGTestHandler") as? NSObject.Type

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
      testHandler?.perform(NSSelectorFromString("setup"))
      let (imageResult, preview) = await display(typeName: typeName, id: id)

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
    await withCheckedContinuation { continuation in
      display(typeName: typeName, id: id) { result, preview in
        continuation.resume(returning: (result, preview))
      }
    }
  }

  @MainActor func display(typeName: String, id: String, completion: @escaping (Result<UIImage, Error>, SnapshotPreviewsCore.Preview) -> Void) {
    let previewTypes = findPreviews { name in
      return name == typeName
    }

    let provider = previewTypes[0]
    let preview = provider.previews.filter { $0.previewId == id }[0]
    try! display(preview: preview) { imageResult, _ in
      completion(imageResult, preview)
    }
  }

  @MainActor func display(preview: SnapshotPreviewsCore.Preview, completion: @escaping (Result<UIImage, Error>, Float?) -> Void) throws {
    var view = preview.view()
    view = AnyView(PreferredColorSchemeWrapper { view })
    view.snapshot(
      layout: preview.layout,
      window: window,
      async: false,
      completion: completion)
  }
  
  @MainActor func writeClassNames() {
    try? FileManager.default.removeItem(at: Self.resultsDir)
    try! FileManager.default.createDirectory(at: Self.resultsDir, withIntermediateDirectories: true)
    
    let snapshotPreviews = ProcessInfo.processInfo.environment["SNAPSHOT_PREVIEWS"];
    let excludedSnapshotPreviews = ProcessInfo.processInfo.environment["EXCLUDED_SNAPSHOT_PREVIEWS"];
    
    var previewsSet: Set<String>? = nil
    if let snapshotPreviews {
      let previewsList = try! JSONDecoder().decode([String].self, from: snapshotPreviews.data(using: .utf8)!)
      previewsSet = Set(previewsList)
    }
    let snapshotPreviewRegexVal = ProcessInfo.processInfo.environment["HANDLE_SNAPSHOT_PREVIEWS_AS_REGEX"];
    let handleSnapshotPreviewsAsRegex = (snapshotPreviewRegexVal! as NSString).boolValue
    
    var excludedPreviewsSet: Set<String>? = nil
    if let excludedSnapshotPreviews {
      let excludedPreviewsList = try! JSONDecoder().decode([String].self, from: excludedSnapshotPreviews.data(using: .utf8)!)
      excludedPreviewsSet = Set(excludedPreviewsList)
    }
    
    let previewTypes = findPreviews { name in
      if let excludedPreviewsSet {
        if #available(iOS 16.0, *) {
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
      }
      
      if let previewsSet {
        if #available(iOS 16.0, *), handleSnapshotPreviewsAsRegex {
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
        } else {
          return previewsSet.contains(name)
        }
      } else {
        return true
      }
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
