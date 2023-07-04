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
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
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
    }
}
