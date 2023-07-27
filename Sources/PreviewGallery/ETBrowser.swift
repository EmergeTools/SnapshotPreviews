//
//  File.swift
//  
//
//  Created by Noah Martin on 7/3/23.
//

import Foundation
import SwiftUI
import SnapshotPreviewsCore

struct PreviewCellView: View {
    let preview: PreviewType

  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Group {
        NavigationLink {
          ScrollView {
            VStack(alignment: .leading) {
              ForEach(preview.previews) { preview in
                VStack {
                  Text(preview.displayName ?? "Preview")
                    .font(.headline)
                    .foregroundStyle(Color(UIColor.label))
                    .padding(.leading, 8)
                  preview.view()
                    .border(Color(UIColor.separator))
                    .background {
                      Checkerboard()
                        .foregroundStyle(Color(UIColor.label))
                        .opacity(0.1)
                    }
                    .preferredColorScheme(nil)
                  Divider()
                }
                .background(Color(UIColor.systemBackground))
                .colorScheme(preview.colorScheme() ?? colorScheme)
              }
            }
          }
          .navigationTitle(preview.displayName)
        } label: {
          HStack {
            VStack(alignment: .leading) {
              Text(preview.displayName)
                .font(.headline)
                .foregroundStyle(Color(UIColor.label))
                .padding(.leading, 8)

              Text("\(preview.previews.count) Preview\(preview.previews.count != 1 ? "s" : "")")
                .font(.subheadline)
                .foregroundStyle(Color(UIColor.secondaryLabel))
                .padding(.leading, 8)
            }
            Spacer()
            Image(systemName: "chevron.right")
              .foregroundColor(Color(UIColor.secondaryLabel))
              .padding(.trailing, 8)
          }
        }

        preview.previews[0].view()
          .border(Color(UIColor.separator))
          .background {
            Checkerboard()
              .foregroundStyle(Color(UIColor.label))
              .opacity(0.1)
          }
          .preferredColorScheme(nil)
      }
      Divider()
    }
    .background(Color(UIColor.systemBackground))
    .colorScheme(preview.previews[0].colorScheme() ?? colorScheme)
  }
}

public struct SnapshotBrowser: View {

  let data: Data

  public init(data: Data = .default) {
    self.data = data
  }

  public var body: some View {
    if data.modules.count > 1 {
      List {
          ForEach(Array(data.modules).sorted(), id: \.self) { module in
            ModulePreviews(module: module, data: data)
          }
      }.navigationTitle("Modules")
    } else {
      ScrollView {
        LazyVStack(alignment: .leading) {
          ForEach(data.previews(in: data.modules.first!)) { preview in
            PreviewCellView(preview: preview)
          }
        }
      }
    }
  }
}
