//
//  CookableApp.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//

import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct CookableApp: App {
    @StateObject private var store = RecipeStore()
    @State private var showMainTabs = false

    // Centralized settings
    @State private var settings = AppSettings()

    // SwiftData model container
    let modelContainer = PersistenceController.shared.container

    init() {
        configureGoogleSignIn()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showMainTabs {
                    MainTabView()
                        .environmentObject(store)
                        .modelContainer(modelContainer)
                } else {
                    SplashView(
                        onFinish: {
                            withAnimation { showMainTabs = true }
                        }
                    )
                    .environmentObject(store)
                }
            }
            // Inject settings once for the whole app
            .environment(settings)
            // Apply app-wide tint and color scheme from centralized settings
            .tint(settings.accentColor)
            .preferredColorScheme(settings.colorScheme)
            .onOpenURL { url in
                // Handle Google Sign-In redirect
                _ = GIDSignIn.sharedInstance.handle(url)
            }
        }
    }

    private func configureGoogleSignIn() {
        // Read the client ID from Info.plist (Key: GIDClientID)
        if let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
           !clientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        } else {
            #if DEBUG
            print("GoogleSignIn: Missing GIDClientID in Info.plist. Set it to your iOS OAuth client ID.")
            #endif
        }
    }
}

