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
    var previewMetadata: [String: [String: String]] = [:]
    previews.forEach { (preview, typeName) in
      if let displayName = preview.displayName {
        previewMetadata[fileName(typeName: typeName, preview: preview)] = [
          "displayName": displayName
        ]
      }
    }
    let data = try! JSONEncoder().encode(previewMetadata)
    try! data.write(to: Self.resultsDir.appending(path: "metadata.json", directoryHint: .notDirectory))
    generateSnapshot()
  }

  private func fileName(typeName: String, preview: Preview) -> String {
    "\(typeName)-\(preview.previewId).png"
  }

  private func generateSnapshot() {
    guard !previews.isEmpty else {
      completion?()
      return
    }

    let (preview, typeName) = previews.removeFirst()
    var view = preview.view()
    if let colorScheme = preview.colorScheme() {
      view = AnyView(view.colorScheme(colorScheme))
    }
    let fileName = fileName(typeName: typeName, preview: preview)
    let file = Self.resultsDir.appending(path: fileName, directoryHint: .notDirectory)
    print(file)
    view.snapshot(layout: preview.layout, window: window, async: false) { image in
          if let pngData = image.pngData() {
              do {
                  try pngData.write(to: file)
              } catch {
                  print("Failed to write \(file)")
                  print(error)
              }
          } else {
              print("Could not generate PNG data for \(file)")
          }
      self.generateSnapshot()
    }
  }
}
