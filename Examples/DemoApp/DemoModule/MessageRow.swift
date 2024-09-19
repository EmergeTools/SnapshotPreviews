//
//  MessageView.swift
//  DemoModule
//
//  Created by Noah Martin on 7/3/23.
//

import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let sender: String
    let content: String
    let isCurrentUser: Bool
}

struct MessageRow: View {
    let message: Message

    var body: some View {
        Group {
            if message.isCurrentUser {
                HStack {
                    Spacer()
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                HStack {
                    Text(message.content)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    Spacer()
                }
            }
        }
    }
}

struct MessageRow_Previews: PreviewProvider {
    static var previews: some View {
      MessageRow(message: Message(sender: "John", content: "Hey, how's it going?", isCurrentUser: false))
        .previewLayout(.sizeThatFits)

      MessageRow(message: Message(sender: "Jane", content: "Hi John! I'm doing great, thanks. How about you?", isCurrentUser: true))
        .previewLayout(.sizeThatFits)
    }
}
