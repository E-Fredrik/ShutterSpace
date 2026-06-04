//
//  MessageListView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 04/06/26.
//

import SwiftUI

struct MessageListView: View {

    @StateObject private var viewModel = MessageListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.recentChats.isEmpty {
                    VStack(spacing: 12.0) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)

                        Text("No messages yet")
                            .font(.headline)

                        Text(
                            "When you contact someone, your conversation will appear here."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    }
                } else {
                    List(viewModel.recentChats) { chat in

                        // NOTE: Ensure your ChatView accepts these parameters
                        NavigationLink(
                            destination: ChatView(
                                recipientId: chat.id,
                                recipientName: chat.partnerName
                            )
                        ) {
                            RecentChatRowView(chat: chat)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                viewModel.fetchRecentChats()
            }
            .onDisappear {
                viewModel.stopListening()
            }
            .preferredColorScheme(.dark)
        }
    }
}
