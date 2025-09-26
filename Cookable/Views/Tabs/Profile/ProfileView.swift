//
//  ProfileView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import UIKit

struct ProfileView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppSettings.self) private var settings

    // Legacy keys (migration support)
    @AppStorage("dietaryPreference") private var legacyDietaryPreference: String = "None"
    @AppStorage("recentlyCooked") private var legacyRecentlyCooked: String = ""

    // History
    @AppStorage("Profile.RecentHistory.JSON") private var recentHistoryJSON: String = "[]"

    // Auth state
    @AppStorage("Profile.User.IsSignedIn") private var isSignedIn: Bool = false
    @AppStorage("Profile.User.DisplayName") private var userDisplayName: String = ""
    @AppStorage("Profile.User.PhotoURL") private var userPhotoURL: String = ""
    @AppStorage("Profile.User.Provider") private var authProvider: String = ""

    // Streaks
    @AppStorage("Profile.Streak.Count") private var streakCount: Int = 0
    @AppStorage("Profile.Streak.LastCookedISO8601") private var lastCookedISO8601: String = ""

    // Local UI state
    @State private var selectedDiets: Set<DietaryPreference> = []
    @State private var selectedAllergies: Set<Allergy> = []
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            Form {
                accountSection
                personalizationSection
                activitySection
                librarySection
                toolsSection
                if isSignedIn {
                    SignOutSection
                }
            }
            .navigationTitle("Profile")
            .onAppear(perform: migrateAndLoad)
            .onChange(of: selectedDiets) {
                saveDietaryPrefs()
            }
            .onChange(of: selectedAllergies) {
                saveAllergies()
            }
        }
    }

    // MARK: - Sections

    private var accountSection: some View {
        Section(header: Text("Account")) {
            if isSignedIn {
                HStack(spacing: 12) {
                    ProfileImageView(urlString: userPhotoURL)
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading) {
                        Text(userDisplayName.isEmpty ? "Signed In" : userDisplayName)
                            .font(.headline)
                        Text(authProvider.isEmpty ? "Synced" : authProvider)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    CButton(icon: "gearshape.fill", kind: .plain, size: .compact, font: .title3, accessibilityLabel: "Advanced Settings") { showingSettings = true }
                    .accessibilityLabel("Advanced Settings")
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sign in to sync favorites, shopping list, and preferences across devices.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    SignInWithAppleButton(.signIn, onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    }, onCompletion: { result in
                        handleAppleSignIn(result: result)
                    })
                    // Use actual environment scheme rather than stored string
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    GoogleSignInButton(
                        viewModel: GoogleSignInButtonViewModel(
                            scheme: colorScheme == .dark ? .dark : .light,
                            style: .wide,
                            state: .normal
                        )
                    ) {
                        handleGoogleSignIn()
                    }
                    .frame(height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            AdvancedSettingsView()
        }
    }

    private var personalizationSection: some View {
        Section(header: Text("Personalization")) {
            NavigationLink {
                DietaryPreferencesView(selected: $selectedDiets)
            } label: {
                HStack {
                    Label("Dietary Preferences", systemImage: "leaf")
                    Spacer()
                    Text(summary(selectedDiets))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            NavigationLink {
                AllergiesSettingsView(selected: $selectedAllergies)
            } label: {
                HStack {
                    Label("Allergies", systemImage: "exclamationmark.triangle")
                    Spacer()
                    Text(summary(selectedAllergies))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            NavigationLink {
                AppearanceSettingsView()
            } label: {
                Label("Appearance", systemImage: "paintpalette")
            }
        }
    }

    private var activitySection: some View {
        Section(header: Text("Activity")) {
            NavigationLink {
                HistoryView()
            } label: {
                Label("History", systemImage: "clock")
            }
        }
    }

    private var librarySection: some View {
        Section(header: Text("Library")) {
            NavigationLink {
                SavedCollectionsView()
            } label: {
                Label("Saved Collections", systemImage: "folder")
            }
        }
    }

    private var toolsSection: some View {
        Section(header: Text("Tools")) {
            NavigationLink {
                RemindersView()
            } label: {
                Label("Reminders", systemImage: "calendar.badge.clock")
            }

            NavigationLink {
                ExportDataView()
            } label: {
                // Fixed SF Symbol name (use dots, not underscore)
                Label("Export Data", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    private var SignOutSection: some View {
        Section {
            CButton(
                title: "Sign Out",
                systemImage: "rectangle.portrait.and.arrow.right",
                kind: .plain,
                size: .regular,
                font: .body
            ) {
                signOut()
            }
            // Ensure the row uses the system foreground (adapts to light/dark)
            .foregroundStyle(.primary)
            // Align with default Form row insets instead of using negative padding
            .listRowInsets(EdgeInsets(top: 6, leading: 5, bottom: 6, trailing: 16))
        }
    }

    // MARK: - Helpers

    private func summary<T: RawRepresentable>(_ set: Set<T>) -> String where T.RawValue == String {
        if set.isEmpty { return "None" }
        let names = set.map { $0.rawValue }.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        return names.prefix(3).joined(separator: ", ") + (names.count > 3 ? " +" : "")
    }

    private func migrateAndLoad() {
        // Migrate legacy single dietaryPreference into multi-select if needed
        if settings.dietaryPrefsJSON == "[]" && legacyDietaryPreference != "None" {
            if let diet = DietaryPreference(rawValue: legacyDietaryPreference) {
                selectedDiets = [diet]
                saveDietaryPrefs()
            }
        } else {
            selectedDiets = decodeSet(from: settings.dietaryPrefsJSON, as: DietaryPreference.self)
        }

        selectedAllergies = decodeSet(from: settings.allergiesJSON, as: Allergy.self)

        if let data = recentHistoryJSON.data(using: .utf8),
           (try? JSONDecoder().decode([RecentRecipeItem].self, from: data))?.isEmpty == true,
           !legacyRecentlyCooked.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let item = RecentRecipeItem(
                id: UUID(),
                recipeID: nil,
                title: legacyRecentlyCooked,
                subtitle: "",
                imageURL: nil,
                viewedAt: Date()
            )
            if let d = try? JSONEncoder().encode([item]), let s = String(data: d, encoding: .utf8) {
                recentHistoryJSON = s
            }
            legacyRecentlyCooked = ""
        }
    }

    private func saveDietaryPrefs() {
        @Bindable var settings = settings
        settings.dietaryPrefsJSON = encodeSet(selectedDiets)
        NotificationCenter.default.post(name: .userPreferencesChanged, object: nil)
    }

    private func saveAllergies() {
        @Bindable var settings = settings
        settings.allergiesJSON = encodeSet(selectedAllergies)
        NotificationCenter.default.post(name: .userPreferencesChanged, object: nil)
    }

    private func signOut() {
        isSignedIn = false
        userDisplayName = ""
        userPhotoURL = ""
        authProvider = ""
    }

    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                userDisplayName = fullName.isEmpty ? "Apple User" : fullName
                authProvider = "Apple"
                isSignedIn = true
            } else {
                userDisplayName = "Apple User"
                authProvider = "Apple"
                isSignedIn = true
            }
        case .failure:
            break
        }
    }

    private func handleGoogleSignIn() {
        guard let presenter = presentingViewController() else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: presenter) { result, error in
            if let error = error {
                print("Google sign-in failed: \(error.localizedDescription)")
                return
            }
            guard let result = result else { return }
            let user = result.user
            let name = user.profile?.name ?? "Google User"
            let imageURL = user.profile?.imageURL(withDimension: 96)?.absoluteString ?? ""

            DispatchQueue.main.async {
                self.userDisplayName = name
                self.userPhotoURL = imageURL
                self.authProvider = "Google"
                self.isSignedIn = true
            }
        }
    }

    private func presentingViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        guard let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return nil }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}

#Preview {
    ProfileView()
}
