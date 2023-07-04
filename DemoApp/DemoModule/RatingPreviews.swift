//
//  RatingPreviews.swift
//  DemoModule
//
//  Created by Noah Martin on 7/5/23.
//

import SwiftUI

struct RatingViews_Previews: PreviewProvider {
    static var previews: some View {
      ForEach(0..<20) { i in
        RatingView(rating: Double(i))
          .previewLayout(.sizeThatFits)
          .padding()
      }
    }
}
