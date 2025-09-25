//
//  FavoritesView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteRecipe.dateAdded, order: .reverse) var favorites: [FavoriteRecipe]

    @State private var newCollection: String = ""
    @State private var selectedCollection: String = "All"

    // All available collections
    var collections: [String] {
        let set = Set(favorites.compactMap { $0.collection })
        return ["All"] + set.sorted()
    }

    // Favorites filtered by collection
    var filteredFavorites: [FavoriteRecipe] {
        selectedCollection == "All"
            ? favorites
            : favorites.filter { $0.collection == selectedCollection }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Picker + Add new collection
                HStack {
                    Picker("Collection", selection: $selectedCollection) {
                        ForEach(collections, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)

                    if !newCollection.isEmpty {
                        Button("Add", action: addCollection)
                    }
                }
                .padding()

                // TextField to create a new collection
                TextField("New collection", text: $newCollection)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                if filteredFavorites.isEmpty {
                    Spacer()
                    Text("No favorites in this collection!")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredFavorites, id: \.id) { (fav: FavoriteRecipe) in
                            HStack {
                                RecipeThumbnail(urlString: fav.imageURL)

                                VStack(alignment: .leading) {
                                    Text(fav.title)
                                        .font(.headline)

                                    Text(fav.subtitle)
                                        .foregroundStyle(.secondary)

                                    if let collection = fav.collection {
                                        Text("Collection: \(collection)")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                }

                                Spacer()

                                // Move recipe between collections
                                Menu {
                                    ForEach(collections.dropFirst(), id: \.self) { col in
                                        Button("Move to \(col)") {
                                            fav.collection = col
                                        }
                                    }
                                    Button("Remove from all collections") {
                                        fav.collection = nil
                                    }
                                } label: {
                                    Image(systemName: "folder")
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .navigationTitle("Favorites")
        }
    }

    // MARK: - Helpers

    private func addCollection() {
        for fav in filteredFavorites {
            fav.collection = newCollection
        }
        selectedCollection = newCollection
        newCollection = ""
    }

    private func delete(_ offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredFavorites[$0] }
        for fav in itemsToDelete {
            if let context = fav.modelContext {
                context.delete(fav)
            }
        }
    }
}

// MARK: - Small AsyncImage helper
struct RecipeThumbnail: View {
    let urlString: String?

    var body: some View {
        if let urlStr = urlString, let url = URL(string: urlStr) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 54, height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Color.gray.opacity(0.2)
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
