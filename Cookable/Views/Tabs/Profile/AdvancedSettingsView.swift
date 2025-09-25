//
//  AdvancedSettingsView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI
import UserNotifications

struct AdvancedSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings
    @State private var isRequestingAuth = false
    @State private var isSendingTest = false
    @State private var lastAuthStatus: UNAuthorizationStatus?

    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications") {
                    @Bindable var settings = settings
                    Toggle("Enable notifications", isOn: $settings.notificationsEnabled)

                    Button {
                        requestNotificationPermission()
                    } label: {
                        if isRequestingAuth {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Label("Request Permission", systemImage: "bell.badge")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Button {
                        sendTestNotification()
                    } label: {
                        if isSendingTest {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Label("Send Test Notification (5s)", systemImage: "paperplane")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .disabled(!settings.notificationsEnabled)

                    if let status = lastAuthStatus {
                        Text("Authorization: \(readable(status))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Text("You can also manage notification permissions in the system Settings app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Sync") {
                    @Bindable var settings = settings
                    Toggle("iCloud Sync", isOn: $settings.iCloudSyncEnabled)
                    Text("Sync favorites, shopping list, and preferences across devices.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("About") {
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    LabeledContent("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await refreshAuthStatus()
            }
        }
    }

    private func requestNotificationPermission() {
        isRequestingAuth = true
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            Task { @MainActor in
                await refreshAuthStatus()
                isRequestingAuth = false
            }
        }
    }

    private func sendTestNotification() {
        isSendingTest = true
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            await MainActor.run {
                lastAuthStatus = settings.authorizationStatus
            }
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                await MainActor.run { isSendingTest = false }
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Cookable Test"
            content.body = "This is a test notification."
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            center.add(request) { _ in
                Task { @MainActor in
                    isSendingTest = false
                }
            }
        }
    }

    @MainActor
    private func refreshAuthStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        lastAuthStatus = settings.authorizationStatus
    }

    private func readable(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
}
