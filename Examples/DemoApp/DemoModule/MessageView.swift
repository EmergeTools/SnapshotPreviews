//
//  MessageView.swift
//  DemoModule
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI

struct MessagingView: View {

    @State private var newMessage = ""

    var body: some View {

          HStack {
              TextField("Type your message...", text: $newMessage)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .padding(.horizontal)

              Button(action: sendMessage) {
                  Image(systemName: "paperplane.fill")
                      .font(.title)
                      .foregroundColor(.blue)
              }
              .padding(.trailing)
          }
          .padding(.vertical)
    }

    func sendMessage() {
        if !newMessage.isEmpty {
            newMessage = ""
        }
    }
}

struct MessageView_Previews: PreviewProvider {
  static var previews: some View {
    MessagingView()
      .previewLayout(.sizeThatFits)
  }
}
