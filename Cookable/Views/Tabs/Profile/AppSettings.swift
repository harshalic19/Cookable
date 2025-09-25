//
//  AppSettings.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

@Observable
final class AppSettings {

    // MARK: - Keys
    private enum Key {
        static let appTheme = "appTheme"
        static let accentColorName = "Profile.AccentColor"
        static let notificationsEnabled = "Settings.Notifications.Enabled"
        static let iCloudSyncEnabled = "Settings.iCloudSync.Enabled"
        static let allergiesJSON = "Profile.Allergies.JSON"
        static let dietaryPrefsJSON = "Profile.DietaryPreferences.JSON"
        static let recentHistoryJSON = "Profile.RecentHistory.JSON"
    }

    // MARK: - Stored values (backed by UserDefaults)
    var appTheme: String {
        didSet { defaults.set(appTheme, forKey: Key.appTheme) }
    }

    var accentColorName: String {
        didSet { defaults.set(accentColorName, forKey: Key.accentColorName) }
    }

    var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: Key.notificationsEnabled) }
    }

    var iCloudSyncEnabled: Bool {
        didSet { defaults.set(iCloudSyncEnabled, forKey: Key.iCloudSyncEnabled) }
    }

    // JSON blobs that other code already uses
    var allergiesJSON: String {
        didSet { defaults.set(allergiesJSON, forKey: Key.allergiesJSON) }
    }

    var dietaryPrefsJSON: String {
        didSet { defaults.set(dietaryPrefsJSON, forKey: Key.dietaryPrefsJSON) }
    }

    var recentHistoryJSON: String {
        didSet { defaults.set(recentHistoryJSON, forKey: Key.recentHistoryJSON) }
    }

    // MARK: - Derived convenience
    var accentColor: Color {
        AccentPalette.color(named: accentColorName)
    }

    var colorScheme: ColorScheme? {
        switch appTheme {
        case "Dark": return .dark
        case "Light": return .light
        default: return nil // System
        }
    }

    // MARK: - Init
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Provide sensible defaults
        self.appTheme = defaults.string(forKey: Key.appTheme) ?? "System"
        self.accentColorName = defaults.string(forKey: Key.accentColorName) ?? "Blue"
        self.notificationsEnabled = defaults.object(forKey: Key.notificationsEnabled) as? Bool ?? true
        self.iCloudSyncEnabled = defaults.object(forKey: Key.iCloudSyncEnabled) as? Bool ?? true
        self.allergiesJSON = defaults.string(forKey: Key.allergiesJSON) ?? "[]"
        self.dietaryPrefsJSON = defaults.string(forKey: Key.dietaryPrefsJSON) ?? "[]"
        self.recentHistoryJSON = defaults.string(forKey: Key.recentHistoryJSON) ?? "[]"
    }
}

