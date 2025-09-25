//
//  HistoryView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

struct HistoryView: View {
    @AppStorage("Profile.RecentHistory.JSON") private var recentHistoryJSON: String = "[]"

    private var items: [RecentRecipeItem] {
        if let data = recentHistoryJSON.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([RecentRecipeItem].self, from: data) {
            return decoded.sorted { $0.viewedAt > $1.viewedAt }
        }
        return []
    }

    var body: some View {
        Form {
            Section {
                if items.isEmpty {
                    ContentUnavailableView("No recent recipes", systemImage: "clock", description: Text("Your last 5 viewed recipes will appear here."))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(items.prefix(5)) { item in
                                RecentItemCard(item: item)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    Button("Clear History", role: .destructive) { clearHistory() }
                        .buttonStyle(.borderless)
                }
            }
        }
        .navigationTitle("History")
        .toolbar(.hidden, for: .tabBar)
    }

    private func clearHistory() {
        recentHistoryJSON = "[]"
    }
}
