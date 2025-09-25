//
//  AppearanceSettingsView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        Form {
            Section(header: Text("Theme")) {
                @Bindable var settings = settings
                Picker("Theme", selection: $settings.appTheme) {
                    Text("Dark").tag("Dark")
                    Text("Light").tag("Light")
                    Text("System").tag("System")
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("Accent Color")) {
                @Bindable var settings = settings
                AccentPaletteView(selectedName: $settings.accentColorName)
            }

            Section(header: Text("Preview")) {
                previewCard
            }
        }
        .navigationTitle("Appearance")
        // Reflect the selection across this screen immediately
        .tint(settings.accentColor)
        // Hide the tab bar while on this screen
        .toolbar(.hidden, for: .tabBar)
        // Do not set .preferredColorScheme here; the app root owns it
    }

    private var previewCard: some View {
        let recipe = Recipe(
            title: "Preview Meal",
            subtitle: "Dessert",
            category: "Dessert",
            cookTimeMinutes: 25,
            calories: 420,
            rating: 4.6,
            imageURL: URL(string: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg"),
            ingredients: ["Sugar - 100g", "Flour - 200g"],
            steps: ["Mix", "Bake"]
        )
        return RecipeCardView(recipe: recipe)
            .tint(settings.accentColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
    }
}
