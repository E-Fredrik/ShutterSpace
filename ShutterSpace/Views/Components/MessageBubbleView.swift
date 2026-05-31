//
//  MessageBubbleView.swift
//  ShutterSpace
//
//  Created by Stevanus Santoso on 28/05/26.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: message.timestamp)
    }
    
    var body: some View {
        if message.isBlocked {
            renderBlockedMessage()
        } else {
            renderNormalMessage()
        }
    }
    
    @ViewBuilder
    private func renderNormalMessage() -> some View {
        VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if message.isFromCurrentUser { Spacer() }
                
                Text(message.content)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isFromCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                
                if !message.isFromCurrentUser { Spacer() }
            }
            
            if message.isFromCurrentUser {
                Text("\(message.status.rawValue) \(timeString)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func renderBlockedMessage() -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text("[MESSAGE UNAVAILABLE]")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            Text(message.content)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack {
        MessageBubbleView(message: Message(id: "1", senderId: "current_user", receiverId: "2", content: "Hello!", timestamp: Date(), status: .delivered))
        MessageBubbleView(message: Message(id: "2", senderId: "2", receiverId: "current_user", content: "Hi there!", timestamp: Date(), status: .read))
    }
    .preferredColorScheme(.dark)
}
