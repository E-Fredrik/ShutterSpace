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
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.vertical)
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
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("Type a message...", text: $viewModel.newMessageText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .focused($isFocused)
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(viewModel.newMessageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(recipientName)
        .navigationBarTitleDisplayMode(.inline)
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
