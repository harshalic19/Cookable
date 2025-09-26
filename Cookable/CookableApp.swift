//
//  CookableApp.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//

import SwiftUI
import SwiftData
import GoogleSignIn
import UserNotifications

@main
struct CookableApp: App {
    @StateObject private var store = RecipeStore()
    @State private var showMainTabs = false

    // Centralized settings
    @State private var settings = AppSettings()

    // SwiftData model container
    let modelContainer = PersistenceController.shared.container

    // Keep the notifications delegate alive for the app lifetime
    private let notificationDelegate = NotificationCenterDelegate()

    init() {
        configureGoogleSignIn()
        configureNotifications()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showMainTabs {
                    MainTabView()
                        .environmentObject(store)
                        .modelContainer(modelContainer)
                        .onReceive(NotificationCenter.default.publisher(for: .openRecipeFromNotification)) { note in
                            // Handle navigation to a specific recipe here if you have a router.
                            // extract the UUID string:
                            if let idString = note.userInfo?["recipeID"] as? String {
                                // Route to the recipe identified by idString
                                #if DEBUG
                                print("Open recipe from notification:", idString)
                                #endif
                            }
                        }
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
                // Handle Google Sign-In redirect and optional deep links
                if GIDSignIn.sharedInstance.handle(url) {
                    return
                }
                // support cookable://recipe/<uuid>
                if url.scheme?.lowercased() == "cookable",
                   url.host?.lowercased() == "recipe",
                   let idString = url.pathComponents.dropFirst().first {
                    NotificationCenter.default.post(name: .openRecipeFromNotification, object: nil, userInfo: ["recipeID": idString])
                }
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

    private func configureNotifications() {
        // Set the notification center delegate so we can present while in foreground
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
}

// MARK: - UNUserNotificationCenterDelegate
private final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {

    // Show notifications while app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }

    // Handle taps to route the user to a recipe
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let idString = userInfo["recipeID"] as? String {
            NotificationCenter.default.post(name: .openRecipeFromNotification, object: nil, userInfo: ["recipeID": idString])
        } else if let deeplink = userInfo["deeplink"] as? String, let url = URL(string: deeplink) {
            // registered a custom URL scheme, forward it
            NotificationCenter.default.post(name: .openRecipeFromNotification, object: nil, userInfo: ["recipeID": url.lastPathComponent])
        }
        completionHandler()
    }
}

// MARK: - Notification.Name helper
extension Notification.Name {
    static let openRecipeFromNotification = Notification.Name("OpenRecipeFromNotification")
}
