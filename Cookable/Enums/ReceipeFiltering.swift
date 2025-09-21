//
//  ReceipeFiltering.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//
import SwiftUI

enum RecipeFiltering {
    static func matchesSearch(_ recipe: Recipe, query: String) -> Bool {
        if recipe.title.lowercased().contains(query) { return true }
        if recipe.subtitle.lowercased().contains(query) { return true }
        let ingredientsText = recipe.ingredients.joined(separator: " ").lowercased()
        if ingredientsText.contains(query) { return true }
        return false
    }

    static func filter(recipes: [Recipe], category: String, searchText: String) -> [Recipe] {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let query = trimmedQuery.lowercased()

        let byCategory: [Recipe]
        switch category {
        case "All":
            byCategory = recipes
        case "Veg":
            // Treat Veg as Vegan only
            byCategory = recipes.filter { $0.category == "Vegan" }
        case "Non-Veg":
            // Exclude Vegan
            byCategory = recipes.filter { $0.category != "Vegan" }
        default:
            byCategory = recipes.filter { $0.category == category }
        }

        if query.isEmpty {
            return byCategory
        }
        return byCategory.filter { RecipeFiltering.matchesSearch($0, query: query) }
    }
}
