//
//  ContentView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var store = RecipeStore()
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var isSearchVisible: Bool = false

    private var filteredRecipes: [Recipe] {
        RecipeFiltering.filter(recipes: store.recipes, category: selectedCategory, searchText: searchText)
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
                        Button("Retry") { Task { await store.loadInitial() } }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            header
                            if isSearchVisible || !searchText.isEmpty {
                                searchBar
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            categoriesBar

                            if filteredRecipes.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 44, weight: .regular))
                                        .foregroundStyle(.secondary)
                                    Text("No recipes in this category")
                                        .font(.headline)
                                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text("Try clearing search or using different keywords.")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .padding(.vertical, 40)
                                .frame(maxWidth: .infinity)
                            } else {
                                recipesGrid
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
                Text("Discover Receipes")
                    .font(.largeTitle.bold())
                Text("Delicious recipes for every day")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                withAnimation(.snappy) {
                    isSearchVisible.toggle()
                }
            } label: {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.tint)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isSearchVisible ? "Hide search" : "Show search")
        }
        .padding(.horizontal)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search recipes, ingredients…", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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

    private var recipesGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
            ForEach(filteredRecipes) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    RecipeCardView(recipe: recipe)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
