//
//  ContentView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 14/05/26.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("currentUserId") private var currentUserId: String = ""
    @AppStorage("currentUserRole") private var currentUserRole: String = ""
    
    var body: some View {
        Group {
            if currentUserId.isEmpty {
                LoginView()
            } else {
                if currentUserRole == "Photographer" {
                    DashboardView()
                } else if currentUserRole == "Admin" {
                    AdminDashboardView() 
                } else {
                    MainView()
                }
            }
        }
        .animation(.easeInOut, value: currentUserId)
    }
}

#Preview {
    ContentView()
}
