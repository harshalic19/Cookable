//
//  DietaryPreferencesView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

struct DietaryPreferencesView: View {
    @Binding var selected: Set<DietaryPreference>
    @Environment(AppSettings.self) private var settings

    var body: some View {
        Form {
            Section {
                TagFlowLayout(DietaryPreference.allCases, spacing: 8) { diet in
                    TagCapsule(
                        text: diet.rawValue,
                        size: .compact,
                        style: .selectableChip,
                        shape: .capsule,
                        leadingSystemImage: diet.icon,
                        isSelected: selected.contains(diet),
                        isEnabled: true
                    ) {
                        if selected.contains(diet) {
                            selected.remove(diet)
                        } else {
                            selected.insert(diet)
                        }
                        @Bindable var settings = settings
                        settings.dietaryPrefsJSON = encodeSet(selected)
                        NotificationCenter.default.post(name: .userPreferencesChanged, object: nil)
                    }
                }
                .padding(.vertical, 4)
                Text("Choose one or more preferences to tailor recipe results.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Dietary Preferences")
        .toolbar(.hidden, for: .tabBar)
    }
}
