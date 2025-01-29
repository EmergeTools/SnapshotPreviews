//
//  ConversationMessageView.swift
//  DemoModule
//
//  Created by Noah Martin on 7/3/23.
//


import SwiftUI

struct Conversation: Identifiable {
    let id = UUID()
    let contactName: String
    let messagePreview: String
    let timestamp: Date
    let unreadCount: Int
}

struct ConversationCellView: View {
    var conversation: Conversation

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.contactName)
                    .font(.headline)

                Text(conversation.messagePreview)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)

                Text(conversation.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
        .padding(8)
    }
}

struct ConversationCellView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationCellView(conversation: Conversation(
          contactName: "John Doe",
          messagePreview: "Hey, how are you?",
          timestamp: Date(),
          unreadCount: 3
        ))
        .previewLayout(.sizeThatFits)
    }
}

extension ProcessInfo {
  var isPreviews: Bool {
    self.environment["EMERGE_IS_RUNNING_FOR_SNAPSHOTS"] == "1" || self.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }
}
