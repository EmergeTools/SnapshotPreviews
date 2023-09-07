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

  public init() {
    let windowScene = UIApplication.shared
      .connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .first

    let window = UIWindow(windowScene: windowScene as! UIWindowScene)
    window.windowLevel = .statusBar + 1
    window.backgroundColor = .red
    window.makeKeyAndVisible()
    self.window = window
  }

  let window: UIWindow

  var previews: [(SnapshotPreviewsCore.Preview, String)] = []

  var errors: [(preview: SnapshotPreviewsCore.Preview, typeName: String, error: Error)] = []

  var completion: (() -> Void)?

  static let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  static let resultsDir = documentsURL.appendingPathComponent("EMGSnapshots")

  func saveSnapshots(completion: @escaping () -> Void) {
    try? FileManager.default.removeItem(at: Self.resultsDir)
    try! FileManager.default.createDirectory(at: Self.resultsDir, withIntermediateDirectories: true)

    self.completion = completion
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
    previews = previewTypes.flatMap { preview in preview.previews.map { ($0, preview.typeName) } }

    generateSnapshot()
  }

  private func writeResults() {
    var previewMetadata: [String: [String: String]] = [:]
    previews.forEach { (preview, typeName) in
      if let displayName = preview.displayName {
        previewMetadata[fileName(typeName: typeName, preview: preview)] = [
          "displayName": displayName
        ]
      }
    }
    errors.forEach { (preview, typeName, error) in
      let name = fileName(typeName: typeName, preview: preview)
      var metadata = previewMetadata[name] ?? [:]
      metadata["error"] = error.localizedDescription
      previewMetadata[name] = metadata
    }
    let data = try! JSONEncoder().encode(previewMetadata)
    try! data.write(to: Self.resultsDir.appendingPathComponent("metadata.json", isDirectory: false))

    completion?()
  }

  private func fileName(typeName: String, preview: SnapshotPreviewsCore.Preview) -> String {
    "\(typeName)-\(preview.previewId).png"
  }

  private func generateSnapshot() {
    guard !previews.isEmpty else {
      writeResults()
      return
    }

    let (preview, typeName) = previews.removeFirst()
    do {
      var view = try preview.view()
      let supportsExpansion = ViewInspection.shouldExpand(view)
      if let colorScheme = try preview.colorScheme() {
        view = AnyView(view.colorScheme(colorScheme))
      }
      let fileName = fileName(typeName: typeName, preview: preview)
      let file = Self.resultsDir.appendingPathComponent(fileName, isDirectory: false)
      print(file)
      view.snapshot(layout: preview.layout, window: window, supportsExpansion: supportsExpansion, async: false) { imageResult in
        do {
          let image = try imageResult.get()
          if let pngData = image.pngData() {
            try pngData.write(to: file)
          } else {
            print("Could not generate PNG data for \(file)")
            self.errors.append((preview, typeName, SnapshotError.pngData))
          }
        } catch {
          print("Failed to write \(file)")
          print(error)
          self.errors.append((preview, typeName, error))
        }
        self.generateSnapshot()
      }
    } catch {
      generateSnapshot()
      errors.append((preview, typeName, error))
    }
  }
}
