//
//  ModulePreviews.swift
//
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import SwiftUI
import SnapshotPreviewsCore

struct ModulePreviews: View {
  let module: String
  let data: PreviewData
  
  var body: some View {
    let componentProviders = data.previews(in: module).filter { provider in
      return provider.previews.contains { preview in
        return !preview.requiresFullScreen
      }
    }
    let featureProviders = data.previews(in: module).filter { provider in
      return provider.previews.contains { preview in
        return preview.requiresFullScreen
      }
    }
    return NavigationLink(module) {
      List {
        if !featureProviders.isEmpty {
          TitleSubtitleRow(
            title: "Screens",
            subtitle: "\(featureProviders.count) Preview\(featureProviders.count != 1 ? "s" : "")")
          .background(
            NavigationLink(destination: ModuleScreens(module: module, data: data), label: {})
                .opacity(0)
          )
          .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
        ForEach(componentProviders) { preview in
          PreviewCellView(preview: preview)
            .allowsHitTesting(false)
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            .frame(width: UIScreen.main.bounds.width)
        }
      }
      .listStyle(.plain)
      .navigationTitle(module)
    }
  }
}
