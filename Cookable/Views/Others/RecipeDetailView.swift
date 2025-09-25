//
//  RecipeDetailView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//

import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings

    // SwiftData Context and Queries
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoriteRecipe]
    @Query private var shoppingItems: [ShoppingListItem]

    // Derived state
    private var isFavorite: Bool {
        favorites.contains(where: { $0.recipeID == recipe.id })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: recipe.imageURL) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Rectangle().fill(Color.gray.opacity(0.2))
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                Rectangle().fill(Color.gray.opacity(0.2))
                                Image(systemName: "photo")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.secondary)
                            }
                        @unknown default:
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(height: 260)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.35), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )

                    CButton(
                        icon: "chevron.left",
                        kind: .plain,
                        size: .compact,
                        font: .system(size: 17, weight: .semibold),
                        accessibilityLabel: "Back"
                    ) {
                        dismiss()
                    }
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
                    .padding()
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    // --- Title and Favorite Heart Button Row ---
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(recipe.title)
                                .font(.title.bold())
                            Text(recipe.subtitle)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        CButton(
                            icon: isFavorite ? "heart.fill" : "heart",
                            kind: .plain,
                            size: .regular,
                            font: .system(size: 28, weight: .semibold),
                            tint: isFavorite ? Color.red : Color(.systemGray3),
                            accessibilityLabel: isFavorite ? "Remove from Favorites" : "Add to Favorites"
                        ) {
                            toggleFavorite()
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal)

                    HStack(spacing: 14) {
                        Label("\(recipe.cookTimeMinutes) min", systemImage: "clock")
                        Label("\(recipe.calories) cal", systemImage: "flame")
                        Label {
                            Text(String(format: "%.1f", recipe.rating))
                        } icon: {
                            Image(systemName: "star.fill").foregroundColor(.yellow)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 2)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.headline)

                    TagFlowLayout(recipe.ingredients, spacing: 10) { item in
                        TagCapsule(
                            text: item,
                            size: .regular,
                            style: .filledNeutral,
                            shape: .capsule
                        )
                    }
                    Spacer(minLength: 12)
                    CButton(title: "Add to Shopping List", systemImage: "cart.badge.plus", kind: .secondary) { addAllIngredientsToShoppingList() }
                }
                .padding(.horizontal)

                if !recipe.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Steps")
                            .font(.headline)
                            .padding(.horizontal)
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    TagCapsule(
                                        text: "\(index + 1)",
                                        size: .compact,
                                        style: .filledAccent,
                                        shape: .capsule
                                    )
                                    Spacer(minLength: 0)
                                }

                                Text(step.replacingOccurrences(of: "^STEP \\d+\\s*", with: "", options: .regularExpression))
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
                            )
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.top)
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            logRecentView()
        }
    }

    // MARK: - Actions

    private func toggleFavorite() {
        if let fav = favorites.first(where: { $0.recipeID == recipe.id }) {
            if let context = fav.modelContext {
                context.delete(fav)
            }
        } else {
            let fav = FavoriteRecipe(
                recipeID: recipe.id,
                title: recipe.title,
                subtitle: recipe.subtitle,
                category: recipe.category,
                imageURL: recipe.imageURL?.absoluteString,
                collection: nil,
                dateAdded: .now
            )
            modelContext.insert(fav)
        }
    }

    private func addAllIngredientsToShoppingList() {
        for ingredient in recipe.ingredients {
            // Avoid duplicates
            if !shoppingItems.contains(where: { $0.name == ingredient && $0.recipeID == recipe.id }) {
                let item = ShoppingListItem(
                    name: ingredient,
                    isChecked: false,
                    recipeID: recipe.id,
                    dateAdded: .now
                )
                modelContext.insert(item)
            }
        }
    }

    // MARK: - Recent history

    private func logRecentView(maxItems: Int = 20, duplicateCooldown: TimeInterval = 30) {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()

        // Decode current list
        let current: [RecentRecipeItem]
        if let data = settings.recentHistoryJSON.data(using: .utf8),
           let decoded = try? decoder.decode([RecentRecipeItem].self, from: data) {
            current = decoded
        } else {
            current = []
        }

        // If the most recent item is the same recipe and within cooldown, skip
        if let first = current.first {
            let sameID = (first.recipeID != nil && first.recipeID == recipe.id)
            let sameTitle = first.title.caseInsensitiveCompare(recipe.title) == .orderedSame
            if (sameID || sameTitle), Date().timeIntervalSince(first.viewedAt) < duplicateCooldown {
                return
            }
        }

        // Remove any existing entry for this recipe (by id if available, else by title)
        let filtered = current.filter { item in
            if let rid = item.recipeID {
                return rid != recipe.id
            } else {
                return item.title.caseInsensitiveCompare(recipe.title) != .orderedSame
            }
        }

        // Prepend the new entry
        let newItem = RecentRecipeItem(
            id: UUID(),
            recipeID: recipe.id,
            title: recipe.title,
            subtitle: recipe.subtitle,
            imageURL: recipe.imageURL,
            viewedAt: Date()
        )
        var updated = [newItem] + filtered

        // Cap the list
        if updated.count > maxItems {
            updated = Array(updated.prefix(maxItems))
        }

        // Encode back to JSON via AppSettings
        if let data = try? encoder.encode(updated),
           let json = String(data: data, encoding: .utf8) {
            @Bindable var settings = settings
            settings.recentHistoryJSON = json
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            title: "Preview Meal",
            subtitle: "Area",
            category: "Dessert",
            cookTimeMinutes: 10,
            calories: 280,
            rating: 4.6,
            imageURL: URL(string: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg"),
            ingredients: ["Sugar - 100g", "Flour - 200g"],
            steps: ["Mix ingredients thoroughly.", "Preheat oven to 180°C.", "Bake for 25 minutes.", "Let it cool and serve."]
        ))
    }
    .preferredColorScheme(.dark)
}
