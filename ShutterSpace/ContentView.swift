//
//  ContentView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 14/05/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Buyer Side
            BrowseView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
            
            // Seller Side
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
        }
        .preferredColorScheme(.dark)
        // Ensures the tab bar matches the dark aesthetic seamlessly
        .tint(.white)
    }
}

#Preview {
    ContentView()
}
