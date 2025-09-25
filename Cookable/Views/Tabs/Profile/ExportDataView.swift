//
//  ExportDataView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//


import SwiftUI
import SwiftData

struct ExportDataView: View {
    @Environment(\.openURL) private var openURL
    @Query private var favorites: [FavoriteRecipe]
    @Query private var shoppingItems: [ShoppingListItem]

    var body: some View {
        Form {
            Section {
                ShareLink(item: exportText) {
                    Label("Export Favorites & Shopping List", systemImage: "square.and.arrow.up")
                }
            }

            Section("Feedback") {
                Button {
                    if let url = URL(string: "mailto:support@example.com?subject=Cookable%20Feedback") {
                        openURL(url)
                    }
                } label: {
                    Label("Send Feedback", systemImage: "envelope")
                }
            }
        }
        .navigationTitle("Export Data")
        .toolbar(.hidden, for: .tabBar)
    }

    private var exportText: String {
        var lines: [String] = []
        lines.append("Cookable Export")
        lines.append("")
        lines.append("Favorites:")
        let grouped = Dictionary(grouping: favorites, by: { $0.collection ?? "Unfiled" })
        for key in grouped.keys.sorted() {
            lines.append("• \(key):")
            for fav in grouped[key] ?? [] {
                lines.append("  - \(fav.title)")
            }
        }
        lines.append("")
        lines.append("Shopping List:")
        for item in shoppingItems {
            lines.append("• \(item.name)\(item.isChecked ? " ✅" : "")")
        }
        return lines.joined(separator: "\n")
    }
}
