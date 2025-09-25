//
//  SearchView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var store: RecipeStore
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    @State private var selectedDiet: String = "Any"
    @State private var minCookTime: Int = 0
    @State private var maxCookTime: Int = 120
    @State private var minCalories: Int = 0
    @State private var maxCalories: Int = 1000
    @State private var showFilters = false

    private var filteredRecipes: [Recipe] {
        RecipeFiltering.advancedFilter(
            recipes: store.recipes,
            query: searchText,
            category: selectedCategory,
            diet: selectedDiet,
            minCookTime: minCookTime,
            maxCookTime: maxCookTime,
            minCalories: minCalories,
            maxCalories: maxCalories
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                HStack {
                    TextField("Search name, ingredient, cuisine...", text: $searchText)
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .disableAutocorrection(true)
                    CButton(icon: "line.3.horizontal.decrease.circle", kind: .plain, size: .regular, font: .title2, accessibilityLabel: "Filters") { showFilters.toggle() }
                }
                .padding(.horizontal)

                if showFilters {
                    VStack(alignment: .leading, spacing: 8) {

                        Picker("Diet", selection: $selectedDiet) {
                            Text("Any").tag("Any")
                            Text("Vegetarian").tag("Vegetarian")
                            Text("Vegan").tag("Vegan")
                            Text("Gluten-Free").tag("Gluten-Free")
                        }
                        .pickerStyle(.segmented)

                        HStack {
                            Text("Cook Time: \(minCookTime)–\(maxCookTime) min")
                            Spacer()
                        }
                        RangeSliderView(value: $minCookTime, value2: $maxCookTime, bounds: 0...120)
                            .frame(height: 24)
                        HStack {
                            Text("Calories: \(minCalories)–\(maxCalories)")
                            Spacer()
                        }
                        RangeSliderView(value: $minCalories, value2: $maxCalories, bounds: 0...1000)
                            .frame(height: 24)
                    }
                    .padding(.horizontal)
                }

                if filteredRecipes.isEmpty {
                    Spacer()
                    Text("No matching recipes.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    List(filteredRecipes) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                        } label: {
                            RecipeCardView(recipe: recipe)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding(.top)
            .navigationTitle("Search")
        }
    }
}
