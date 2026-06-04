//
//  RecentChatRowView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 04/06/26.
//


import SwiftUI

struct RecentChatRowView: View {
    let chat: RecentChat
    
    var body: some View {
        HStack(spacing: 16.0) {
            
            // 1. Instantly show placeholder if URL is empty or invalid
            if chat.partnerImageUrl.isEmpty || !chat.partnerImageUrl.starts(with: "http") {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56.0, height: 56.0)
                    .foregroundColor(Color(UIColor.systemGray3))
            } else {
                // 2. Load the Cloudinary image if it is a valid network link
                AsyncImage(url: URL(string: chat.partnerImageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.secondarySystemBackground))
                            ProgressView()
                        }
                        .frame(width: 56.0, height: 56.0)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56.0, height: 56.0)
                            .clipShape(Circle())
                    case .failure(_):
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56.0, height: 56.0)
                            .foregroundColor(Color(UIColor.systemGray3))
                    @unknown default:
                        EmptyView()
                            .frame(width: 56.0, height: 56.0)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4.0) {
                HStack {
                    Text(chat.partnerName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(formatInboxDate(chat.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 8.0)
    }
    
    // Mimics the native Apple iOS Messages timestamp logic
    private func formatInboxDate(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            return formatter.string(from: date)
        }
    }
}
