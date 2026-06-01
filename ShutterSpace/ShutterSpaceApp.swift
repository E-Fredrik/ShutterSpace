//
//  ShutterSpaceApp.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 14/05/26.
//

import SwiftUI
import Combine
import FirebaseCore
import FirebaseAppCheck 

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        
        FirebaseApp.configure()
        return true
    }
}

@main
struct ShutterSpaceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
