//
//  ContentView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 14/05/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ContentView: View {
    
    @AppStorage("currentUserId") private var currentUserId: String = ""
    @AppStorage("currentUserRole") private var currentUserRole: String = ""
    
    // Alert State Properties
    @State private var showStatusAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    // FIXED: Added observedUserId to prevent Observer Leaks
    @State private var statusObserverHandle: DatabaseHandle?
    @State private var observedUserId: String = ""
    
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
        .onAppear {
            setupStatusObserver()
        }
        .onChange(of: currentUserId) { _ in
            setupStatusObserver()
        }
        .alert(isPresented: $showStatusAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    forceLogout()
                }
            )
        }
    }
    
    // MARK: - Real-Time Status Monitoring
    
    private func setupStatusObserver() {
        // 1. Safely remove the observer from the PREVIOUS user using the explicit tracked ID
        if let handle = statusObserverHandle, !observedUserId.isEmpty {
            Database.database().reference().child("users").child(observedUserId).child("status").removeObserver(withHandle: handle)
            statusObserverHandle = nil
        }
        
        // 2. Update the tracker to the new current user ID
        observedUserId = currentUserId
        
        // 3. Stop here if no one is actually logged in
        guard !observedUserId.isEmpty else { return }
        
        let statusRef = Database.database().reference().child("users").child(observedUserId).child("status")
        
        // 4. Attach a fresh listener specifically for the current logged-in user
        statusObserverHandle = statusRef.observe(.value) { snapshot in
            if let currentStatus = snapshot.value as? String {
                if currentStatus == "Banned" {
                    alertTitle = "Account Banned"
                    alertMessage = "This account has been permanently banned for violating ShutterSpace Terms of Service."
                    showStatusAlert = true
                } else if currentStatus == "Suspended" {
                    alertTitle = "Account Suspended"
                    alertMessage = "This account is temporarily suspended. Please contact ShutterSpace support for details."
                    showStatusAlert = true
                }
            }
        }
    }
    
    private func forceLogout() {
        // Clean up the observer immediately using the tracked ID before wiping the session
        if let handle = statusObserverHandle, !observedUserId.isEmpty {
            Database.database().reference().child("users").child(observedUserId).child("status").removeObserver(withHandle: handle)
        }
        statusObserverHandle = nil
        observedUserId = ""
        
        try? Auth.auth().signOut()
        currentUserId = ""
        currentUserRole = ""
    }
}

#Preview {
    ContentView()
}
