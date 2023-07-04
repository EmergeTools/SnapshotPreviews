//
//  CodeEntryView.swift
//  DemoApp
//
//  Created by Noah Martin on 7/27/23.
//

import Foundation
import SwiftUI

struct CodeEntryView: View {
    var body: some View {
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        CodeDigitView()
                        .frame(height: 40)
                    }
        }
    }
}

struct CodeDigitView: View {
  @State var size: CGFloat = 0

    var body: some View {
      Rectangle().frame(width: size).background {
        GeometryReader { geometry in
          Color.clear.onAppear {
            size = geometry.size.height
          }
        }
      }
    }
}

struct CodeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        CodeEntryView()
    }
}
