//
//  DemoApp.swift
//  Demo Watch App
//
//  Created by Noah Martin on 7/5/24.
//

import SwiftUI
import PreviewGallery

@main
struct Demo_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
          NavigationStack {
            PreviewGallery()
          }
        }
    }
}
