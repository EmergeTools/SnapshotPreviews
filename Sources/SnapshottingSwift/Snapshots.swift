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
import Vapor

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

  let app = try! Application(.detect())

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

    app.get("display", ":class", ":id") { [weak self] req -> EventLoopFuture in
      let typeName = req.parameters.get("class")!
      let id = req.parameters.get("id")!
      let promise = req.eventLoop.makePromise(of: [String: String].self)
      DispatchQueue.main.async {
        self?.display(typeName: typeName, id: id) { imageResult, preview in
          var result: [String: String] = [:]
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
              promise.succeed(result)
            } else {
              print("Could not generate PNG data for \(file)")
              result["error"] = SnapshotError.pngData.localizedDescription
              promise.succeed(result)
            }
          } catch {
            print("Failed to write \(file)")
            print(error)
            result["error"] = error.localizedDescription
            promise.succeed(result)
          }
        }
      }
      return promise.futureResult;
    }
    app.get("file") { req in
      return Self.resultsDir.path
    }
    try! app.start()
  }

  let window: UIWindow

  var previews: [(SnapshotPreviewsCore.Preview, String)] = []

  var errors: [(preview: SnapshotPreviewsCore.Preview, typeName: String, error: Error)] = []

  var completion: (() -> Void)?

  static let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  static let resultsDir = documentsURL.appendingPathComponent("EMGSnapshots")

  @MainActor func display(typeName: String, id: String, completion: @escaping (Result<UIImage, Error>, SnapshotPreviewsCore.Preview) -> Void) {
    let previewTypes = findPreviews { name in
      return name == typeName
    }

    let provider = previewTypes[0]
    let preview = provider.previews.filter { $0.previewId == id }[0]
    try! display(preview: preview) { imageResult in
      completion(imageResult, preview)
    }
  }

  @MainActor func display(preview: SnapshotPreviewsCore.Preview, completion: @escaping (Result<UIImage, Error>) -> Void) throws {
    var view = try preview.view()
    let supportsExpansion = ViewInspection.shouldExpand(view)
    let renderingMode = ViewInspection.renderingMode(of: view)
    if let colorScheme = try preview.colorScheme() {
      view = AnyView(view.colorScheme(colorScheme))
    }
    view.snapshot(
      layout: preview.layout,
      window: window,
      supportsExpansion: supportsExpansion,
      renderingMode: renderingMode,
      async: false,
      completion: completion)
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
