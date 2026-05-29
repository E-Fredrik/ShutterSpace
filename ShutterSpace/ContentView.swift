//
//  ContentView.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 14/05/26.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("currentUserId") private var currentUserId: String = ""
    
    var body: some View {
        if currentUserId.isEmpty {
            LoginView()
        } else {
            MainView()
        }
    }
}

#Preview {
    ContentView()
}
