//
//  AdminUserDetailView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 03/06/26.
//
import SwiftUI

struct AdminUserDetailView: View {
    let user: User

    @StateObject private var viewModel: AdminUserDetailViewModel

    init(user: User) {
        self.user = user
        // Pass the user into the ViewModel during initialization
        _viewModel = StateObject(
            wrappedValue: AdminUserDetailViewModel(user: user)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24.0) {

                // MARK: - Header Profile Section
                VStack(spacing: 8.0) {
                    Image(
                        systemName: "person.crop.circle.badge.exclamationmark"
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.red)
                    .padding(.bottom, 8)

                    Text("\(user.firstName) \(user.lastName)")
                        .font(.title)
                        .fontWeight(.bold)

                    Text(user.email)
                        .foregroundColor(.secondary)

                    Text("ID: \(user.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("Current Status:")
                        // Bind directly to the view model's published status
                        Text(viewModel.currentStatus)
                    }
                    .font(.headline)
                    .foregroundColor(statusColor(viewModel.currentStatus))
                    .padding(.top, 4)
                }

                // MARK: - Account Actions
                VStack(alignment: .leading, spacing: 12.0) {
                    Text("Account Actions")
                        .font(.title3)
                        .fontWeight(.bold)

                    HStack(spacing: 12.0) {
                        Button("Reactivate") {
                            Task { await viewModel.changeStatus(to: "Active") }
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Button("Suspend") {
                            Task {
                                await viewModel.changeStatus(to: "Suspended")
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.orange.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Button("Ban User") {
                            Task { await viewModel.changeStatus(to: "Banned") }
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                // MARK: - Recent Chat Logs
                VStack(alignment: .leading, spacing: 16.0) {
                    HStack {
                        Text("Recent Chat Logs")
                            .font(.title3)
                            .fontWeight(.bold)

                        Spacer()

                        Button("Refresh") {
                            viewModel.fetchChatLogs(forUserId: user.id)
                        }
                        .font(.subheadline)
                    }

                    if viewModel.isLoadingLogs && viewModel.chatLogs.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if viewModel.chatLogs.isEmpty {
                        Text("No recent messages found for this user.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(
                                Color(UIColor.secondarySystemBackground)
                            )
                            .cornerRadius(12.0)
                    } else {
                        // Constrain height so it scrolls independently inside the main view
                        ScrollView {
                            LazyVStack(spacing: 12.0) {
                                ForEach(viewModel.chatLogs) { log in
                                    renderChatLogRow(
                                        message: log,
                                        targetUserId: user.id
                                    )
                                }
                            }
                        }
                        .frame(maxHeight: 400)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Manage User")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .task {
            // Fetch the initial status and bind the chat logs listener
            await viewModel.fetchInitialData()
        }
        .onDisappear {
            viewModel.stopObservingLogs()
        }
    }

    // MARK: - Helper Methods

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "suspended": return .orange
        case "banned": return .red
        default: return .secondary
        }
    }
}

// MARK: - Extracted Components

extension AdminUserDetailView {

    @ViewBuilder
    func renderChatLogRow(message: Message, targetUserId: String) -> some View {
        let isSender = message.senderId == targetUserId

        VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                Text(isSender ? "Sent" : "Received")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8.0)
                    .padding(.vertical, 4.0)
                    .background(
                        isSender
                            ? Color.blue.opacity(0.2) : Color.green.opacity(0.2)
                    )
                    .foregroundColor(isSender ? .blue : .green)
                    .cornerRadius(6.0)

                Text(
                    isSender
                        ? "To: \(message.receiverId.prefix(8))..."
                        : "From: \(message.senderId.prefix(8))..."
                )
                .font(.caption)
                .foregroundColor(.secondary)

                Spacer()

                Text(
                    message.timestamp.formatted(
                        .dateTime.month().day().hour().minute()
                    )
                )
                .font(.caption2)
                .foregroundColor(.secondary)
            }

            Text(message.content)
                .font(.subheadline)
                .foregroundColor(message.isBlocked ? .red : .primary)
                .italic(message.isBlocked)

            if !message.isBlocked {
                Button(action: {
                    // We now pass the entire 'message' object instead of just 'message.id'
                    Task { await viewModel.blockMessage(message: message) }
                }) {
                    HStack {
                        Image(systemName: "nosign")
                        Text("Block Message")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4.0)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12.0)
    }
}

#Preview {
    AdminUserDetailView(
        user: User(
            id: "12345",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            role: "Admin"
        )
    )
}
