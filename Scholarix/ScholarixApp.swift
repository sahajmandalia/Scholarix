//
//  ScholarixApp.swift
//  Scholarix
//
//  Created by Kunal Mandalia on 10/12/25.
//

import SwiftUI
import FirebaseCore

@main
struct ScholarixApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var sessionManager = SessionManager()
    
    // Initialize ThemeManager here
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .environmentObject(themeManager)
                // This line performs the magic switch
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    // Smart check on launch
                    NotificationManager.shared.checkPermissions()
                }
        }
    }
}
