//
//  AllergiesSettingsView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

struct AllergiesSettingsView: View {
    @Binding var selected: Set<Allergy>
    @Environment(AppSettings.self) private var settings

    var body: some View {
        Form {
            Section {
                TagFlowLayout(Allergy.allCases, spacing: 8) { allergy in
                    SelectableChip(
                        title: allergy.rawValue,
                        isSelected: selected.contains(allergy),
                        systemImage: allergy.icon
                    ) {
                        if selected.contains(allergy) { selected.remove(allergy) } else { selected.insert(allergy) }
                        // Persist via centralized settings
                        @Bindable var settings = settings
                        settings.allergiesJSON = encodeSet(selected)
                        NotificationCenter.default.post(name: .userPreferencesChanged, object: nil)
                    }
                }
                .padding(.vertical, 4)
                Text("We’ll try to hide recipes containing these allergens.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Allergies")
        .toolbar(.hidden, for: .tabBar)
    }
}
