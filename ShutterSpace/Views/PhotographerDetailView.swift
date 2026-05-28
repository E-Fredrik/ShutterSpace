//
//  PhotographerDetailView.swift
//  ShutterSpace
//
//  Created by Stevanus Santoso on 28/05/26.
//

import SwiftUI

struct PhotographerDetailView: View {
    let photographer: Photographer
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Profile Header
                HStack(spacing: 20) {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 100, height: 100)
                        .overlay(Text(photographer.firstName.prefix(1)))
                    
                    VStack(alignment: .leading) {
                        Text("\(photographer.firstName) \(photographer.lastName)")
                            .font(.title)
                            .bold()
                        Text(photographer.category)
                            .foregroundColor(.secondary)
                        Text("★ \(String(format: "%.1f", photographer.rating))")
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
                
                // Action Buttons
                HStack(spacing: 16) {
                    NavigationLink(destination: ChatView(recipientId: photographer.id, recipientName: photographer.firstName)) {
                        Label("Message", systemImage: "message.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {}) {
                        Label("Book Now", systemImage: "calendar")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Bio / Portfolio Placeholder
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .font(.headline)
                    Text("Professional \(photographer.category) photographer based in \(photographer.location). Providing high-quality captures for your special moments.")
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Spacer()
            }
        }
        .navigationTitle(photographer.firstName)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationStack {
        PhotographerDetailView(photographer: Photographer(id: "1", firstName: "Alice", lastName: "Smith", startingPrice: 200, rating: 4.8, location: "NY", category: "Wedding", profileImageURL: ""))
    }
}
