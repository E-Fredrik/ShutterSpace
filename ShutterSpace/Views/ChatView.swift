//
//  ChatView.swift
//  ShutterSpace
//
//  Created by Stevanus Santoso on 28/05/26.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isFocused: Bool
    
    init(recipientId: String, recipientName: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(recipientId: recipientId))
        self.recipientName = recipientName
    }
    
    let recipientName: String
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        Text("Today 2:14 PM")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top)
                            
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                }
                .onChange(of: viewModel.messages) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
                .onAppear {
                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
            }
            
            HStack(spacing: 12) {
                TextField("iMessage", text: $viewModel.newMessageText)
                    .padding(10)
                    .padding(.horizontal, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .focused($isFocused)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(viewModel.newMessageText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 2)
        }
        .navigationTitle(recipientName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
            }
        }
        .alert("Policy Warning", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationStack {
        ChatView(recipientId: "1", recipientName: "Alice Smith")
    }
}
