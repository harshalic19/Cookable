//
//  ReceipeFiltering.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//
import SwiftUI
import Foundation

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
            byCategory = recipes.filter { $0.category == "Vegan" }
        case "Non-Veg":
            byCategory = recipes.filter { $0.category != "Vegan" }
        default:
            byCategory = recipes.filter { $0.category == category }
        }

        // Apply allergy exclusion
        let allergies = selectedAllergies()
        let byAllergies = byCategory.filter { !shouldExclude(recipe: $0, allergies: allergies) }

        if query.isEmpty {
            return byAllergies
        }
        return byAllergies.filter { matchesSearch($0, query: query) }
    }

    static func advancedFilter(
        recipes: [Recipe],
        query: String,
        category: String,
        diet: String,
        minCookTime: Int,
        maxCookTime: Int,
        minCalories: Int,
        maxCalories: Int
    ) -> [Recipe] {
        let lowered = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let allergies = selectedAllergies()

        return recipes.filter { recipe in
            (lowered.isEmpty || matchesSearch(recipe, query: lowered))
            && (category == "All" || recipe.category == category)
            && (diet == "Any"
                || (diet == "Vegetarian" && recipe.category == "Veg")
                || (diet == "Vegan" && recipe.category == "Vegan")
                || (diet == "Gluten-Free" && recipe.ingredients.contains(where: { $0.lowercased().contains("gluten-free") })))
            && recipe.cookTimeMinutes >= minCookTime
            && recipe.cookTimeMinutes <= maxCookTime
            && recipe.calories >= minCalories
            && recipe.calories <= maxCalories
            && !shouldExclude(recipe: recipe, allergies: allergies)
        }
    }
}

// MARK: - Allergy helpers

private func selectedAllergies() -> Set<Allergy> {
    // Read the JSON string directly from UserDefaults (same key as @AppStorage)
    let key = "Profile.Allergies.JSON"
    let json = UserDefaults.standard.string(forKey: key) ?? "[]"
    return decodeSet(from: json, as: Allergy.self)
}

private func shouldExclude(recipe: Recipe, allergies: Set<Allergy>) -> Bool {
    if allergies.isEmpty { return false }

    // Normalize all ingredient strings to lowercase, strip diacritics
    let normalizedIngredients: [String] = recipe.ingredients.map { normalize($0) }

    for allergy in allergies {
        for keyword in allergy.keywords {
            let k = normalize(keyword)
            for ingredient in normalizedIngredients {
                // Special case: don't exclude for "gluten" if it's explicitly "gluten-free"
                if k == "gluten" && ingredient.contains("gluten-free") {
                    continue
                }
                if ingredient.contains(k) {
                    return true
                }
            }
        }
    }
    return false
}

private func normalize(_ s: String) -> String {
    s.lowercased()
        .folding(options: .diacriticInsensitive, locale: .current)
}

