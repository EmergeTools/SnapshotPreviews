//
//  RideShareButton.swift
//  DemoApp
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI

struct RideShareButtonView: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(UIColor.systemBackground))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.label))
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RideShareButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RideShareButtonView(title: "Request Ride") {
            print("Button tapped")
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Ride Share Button View - Light")

      RideShareButtonView(title: "Request Ride") {
          print("Button tapped")
      }
      .previewDisplayName("Ride Share Button View - Dark")
      .preferredColorScheme(.dark)
      .previewLayout(.sizeThatFits)
      .padding()
    }
}
