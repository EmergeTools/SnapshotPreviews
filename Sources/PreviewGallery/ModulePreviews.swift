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
        ScrollView {
          LazyVStack(alignment: .leading) {
            if !featureProviders.isEmpty {
              NavigationLink {
                ModuleFeatures(module: module, data: data)
              } label: {
                VStack {
                  TitleSubtitleRow(
                    title: "Screens",
                    subtitle: "\(featureProviders.count) Preview\(featureProviders.count != 1 ? "s" : "")")
                  Divider()
                }
              }
            }
            ForEach(componentProviders) { preview in
              PreviewCellView(preview: preview)
            }
          }
        }
        .navigationTitle(module)
      }
  }
}
