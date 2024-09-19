//
//  RatingView.swift
//  DemoModule
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI

struct RatingView: View {
    var rating: Double

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Image(systemName: rating >= Double(index + 1) ? "star.fill" : "star")
                .foregroundColor(Color(PlatformColor.systemYellow))
                    .font(.body)
            }
        }
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        RatingView(rating: 5.0)
          .previewLayout(.sizeThatFits)
          .padding()

        RatingView(rating: 4.9)
          .previewLayout(.sizeThatFits)
          .padding()
          .preferredColorScheme(.dark)

        RatingView(rating: 4.8)
          .previewLayout(.sizeThatFits)
          .padding()

        RatingView(rating: 4.7)
          .previewLayout(.sizeThatFits)
          .padding()

        RatingView(rating: 4.6)
          .previewLayout(.sizeThatFits)
          .padding()

        RatingView(rating: 4.5)
          .previewLayout(.sizeThatFits)
          .padding()
      }

          RatingView(rating: 4.4)
              .previewLayout(.sizeThatFits)
              .padding()

          RatingView(rating: 4.3)
              .previewLayout(.sizeThatFits)
              .padding()

          RatingView(rating: 4.2)
                .previewLayout(.sizeThatFits)
                .padding()

          RatingView(rating: 4.1)
                .previewLayout(.sizeThatFits)
                .padding()

          RatingView(rating: 4.0)
              .previewLayout(.sizeThatFits)
              .padding()

          RatingView(rating: 3.9)
              .previewLayout(.sizeThatFits)
              .padding()

          RatingView(rating: 3.8)
              .previewLayout(.sizeThatFits)
              .padding()

          RatingView(rating: 3.7)
              .previewLayout(.sizeThatFits)
              .padding()
    }
}
