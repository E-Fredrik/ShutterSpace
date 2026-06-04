//
//  MainView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            BrowseView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }

            MySessionsView()
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text("My Sessions")
                }
            MessageListView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Messages")
                }

            UserProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }

        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainView()
}
