//
//  SavedCollectionsView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI
import SwiftData

struct SavedCollectionsView: View {
    @Query private var favorites: [FavoriteRecipe]

    private var collectionNames: [String] {
        let names = Set(favorites.compactMap { $0.collection?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty })
        return names.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var body: some View {
        List {
            if collectionNames.isEmpty {
                Section {
                    Text("Create collections by assigning favorites to a collection in the recipe page.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Section {
                    ForEach(collectionNames, id: \.self) { name in
                        let items = favorites.filter { $0.collection == name }
                        NavigationLink {
                            CollectionDetailView(name: name, items: items)
                                .toolbar(.hidden, for: .tabBar)
                        } label: {
                            HStack {
                                Image(systemName: "folder.fill").foregroundStyle(.tertiary)
                                Text(name)
                                Spacer()
                                Text("\(items.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Collections")
        .toolbar(.hidden, for: .tabBar)
    }
}
