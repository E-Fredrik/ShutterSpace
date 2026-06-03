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
    
    // Bypass for UI Testing
    private var isUITestingAdmin: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITest_AdminMode")
    }
    
    var body: some View {
        Group {
            if isUITestingAdmin {
                AdminDashboardView()
            } else if currentUserId.isEmpty {
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
