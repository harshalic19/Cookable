//
//  DiscoverView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var store: RecipeStore
    @Environment(AppSettings.self) private var settings
    @State private var selectedCategory: String = "All"

    // MARK: - Section Filtering Logic
    private var trending: [Recipe] {
        store.recipes.sorted { $0.rating > $1.rating }.prefix(8).map { $0 }
    }
    private var quickMeals: [Recipe] {
        store.recipes.filter { $0.cookTimeMinutes <= 25 }.prefix(8).map { $0 }
    }
    private var seasonal: [Recipe] {
        // For demo: use random selection
        store.recipes.shuffled().prefix(8).map { $0 }
    }
    private var newRecipes: [Recipe] {
        store.recipes.sorted { $0.id.uuidString > $1.id.uuidString }.prefix(8).map { $0 }
    }

    private var filteredRecipes: [Recipe] {
        // Allergy exclusion is applied inside RecipeFiltering.filter.
        _ = settings.allergiesJSON
        return RecipeFiltering.filter(recipes: store.recipes, category: selectedCategory, searchText: "")
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading recipes…").foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = store.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.yellow)
                        Text("Failed to load recipes").font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        CButton(title: "Retry", kind: .primary) { await store.loadInitial() }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            header
                            categoriesBar

                            if filteredRecipes.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 44, weight: .regular))
                                        .foregroundStyle(.secondary)
                                    Text("No recipes in this category")
                                        .font(.headline)
                                }
                                .padding(.vertical, 40)
                                .frame(maxWidth: .infinity)
                            } else {
                                // Sectioned grid
                                ForEach(sectionedData, id: \.title) { section in
                                    if !section.recipes.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(section.title)
                                                .font(.title2.bold())
                                                .padding(.horizontal)
                                                .padding(.top, 8)
                                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                                                ForEach(section.recipes) { recipe in
                                                    NavigationLink {
                                                        RecipeDetailView(recipe: recipe)
                                                    } label: {
                                                        RecipeCardView(recipe: recipe)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.bottom, 8)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Discover Recipes")
                    .font(.largeTitle.bold())
                Text("Delicious recipes for every day")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var categoriesBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(store.categories, id: \.self) { category in
                    let isSelected = (category == selectedCategory)
                    let style: TagCapsule.Style = isSelected ? .outlinedAccent : .outlinedNeutral
                    let icon = (category != "All") ? store.symbol(for: category) : nil

                    TagCapsule(
                        text: category,
                        size: .regular,
                        style: style,
                        shape: .capsule,
                        leadingSystemImage: icon
                    ) {
                        withAnimation(.snappy) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private struct SectionData: Identifiable {
        let id = UUID()
        let title: String
        let recipes: [Recipe]
    }

    private var sectionedData: [SectionData] {
        [
            SectionData(title: "Trending", recipes: trending),
            SectionData(title: "New", recipes: newRecipes),
            SectionData(title: "Seasonal", recipes: seasonal),
            SectionData(title: "Quick Meals", recipes: quickMeals)
        ]
    }
}

#Preview {
    DiscoverView()
        .environmentObject(RecipeStore())
}

