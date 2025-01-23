//
//  PreviewGallery.swift
//
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import SwiftUI
import SnapshotPreviewsCore

struct PreviewCellView: View {
  let previewGrouping: PreviewGrouping

  var previews: [SnapshotPreviewsCore.Preview] {
    previewGrouping.previews.flatMap { $0.previews(requiringFullscreen: false)}
  }

  var body: some View {
    VStack(alignment: .center) {
      TitleSubtitleRow(
        title: previewGrouping.displayName,
        subtitle: "\(previews.count) Preview\(previews.count != 1 ? "s" : "")"
      )
      .padding(EdgeInsets(top: 12, leading: 16, bottom: 6, trailing: 16))

      PreviewCell(preview: previews[0])
    }
    .padding(.bottom, 8)
  }
}

/// A SwiftUI View that displays a gallery of previews organized by modules.
///
/// `PreviewGallery` presents a list of modules, each containing its respective previews.
/// If no previews are found, it displays a message indicating so.
///
/// It should be created within a `NavigationStack`.
///
/// # Example
/// ```swift
/// struct GalleryApp: App {
///    var body: some Scene {
///        WindowGroup {
///          NavigationStack {
///            PreviewGallery()
///          }
///        }
///     }
///  }
/// ```
public struct PreviewGallery: View {
  /// The data source containing preview information.
  let data: PreviewData
  
  @State private var searchText = ""

  /// Initializes a new `PreviewGallery` with the given preview data.
  ///
  /// - Parameter data: The `PreviewData` to use for populating the gallery.
  ///   If `nil`, the default `PreviewData` will be used.
  @MainActor
  public init(data: PreviewData? = nil) {
    self.data = data ?? .default
  }

  public var body: some View {
    if data.modules.count > 0 {
      List {
        ForEach(Array(data.modules).sorted().filterWithText(searchText, { $0 }), id: \.self) { module in
          ModulePreviews(module: module, data: data)
        }
      }
      .navigationTitle("Modules")
      .searchable(text: $searchText)
    } else {
      Text("No previews found")
    }
  }
}
