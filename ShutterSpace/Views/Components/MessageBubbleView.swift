//
//  MessageBubbleView.swift
//  ShutterSpace
//
//  Created by Stevanus Santoso on 28/05/26.
//

import SwiftUI

struct MessageBubbleView: View {

    let message: Message

    // 1. Automatically grab the real logged-in ID from the device
    @AppStorage("currentUserId") private var currentUserId: String = ""

    // 2. Compare the message's sender ID to your real ID
    var isFromCurrentUser: Bool {
        return message.senderId == currentUserId
    }

    var body: some View {
        HStack {

            // If it's you, push the bubble to the right
            if isFromCurrentUser {
                Spacer()
            }

            Text(message.content)
                .padding(.horizontal, 16.0)
                .padding(.vertical, 12.0)
                // 3. Dynamically color the bubble based on who sent it
                .background(
                    isFromCurrentUser ? Color.blue : Color(UIColor.darkGray)
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18.0))

            // If it's the other person, push the bubble to the left
            if !isFromCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4.0)
    }
}

#Preview {
    VStack {
        MessageBubbleView(
            message: Message(
                id: "1",
                senderId: "current_user",
                receiverId: "2",
                content: "Hello!",
                timestamp: Date(),
                status: .delivered
            )
        )
        MessageBubbleView(
            message: Message(
                id: "2",
                senderId: "2",
                receiverId: "current_user",
                content: "Hi there!",
                timestamp: Date(),
                status: .read
            )
        )
    }
    .preferredColorScheme(.dark)
}
