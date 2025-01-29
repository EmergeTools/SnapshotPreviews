//
//  ModulePreviews.swift
//
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import SwiftUI

struct ModulePreviews: View {
  let module: String
  let data: PreviewData
  
  @State private var searchText = ""

  var body: some View {
    let allPreviewGroups = data.previews(in: module)
    let componentProviders = allPreviewGroups.filter { provider in
      provider.previewTypes(requiringFullscreen: false).count > 0
    }.filterWithText(searchText, { $0.displayName })
    let fullScreenCount = allPreviewGroups.flatMap { $0.previews.flatMap { $0.previews(requiringFullscreen: true)} }.count
    return NavigationLink(module) {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 12) {
          if fullScreenCount > 0 && (searchText.isEmpty || "screens".contains(searchText.lowercased())) {
            NavigationLink(destination: ModuleScreens(module: module, data: data)) {
              TitleSubtitleRow(
                title: "Screens",
                subtitle: "\(fullScreenCount) Preview\(fullScreenCount != 1 ? "s" : "")")
              .padding(16)
              #if !os(watchOS)
              .background(Color(PlatformColor.gallerySecondaryBackground))
              #endif
            }
          }
          ForEach(componentProviders) { preview in
            NavigationLink(destination: PreviewsDetail(previewGrouping: preview)) {
              PreviewCellView(previewGrouping: preview)
              #if !os(watchOS)
                .background(Color(PlatformColor.gallerySecondaryBackground))
              #endif
                .allowsHitTesting(false)
            }
            #if canImport(UIKit) && !os(visionOS) && !os(watchOS)
            .frame(width: UIScreen.main.bounds.width)
            #endif
          }
        }
      }
      #if !os(watchOS)
      .background(Color(PlatformColor.galleryBackground))
      #endif
      .navigationTitle(module)
      .searchable(text: $searchText)
    }
  }
}
