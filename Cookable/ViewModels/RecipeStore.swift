//
//  RecipeStore.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//

import SwiftUI
import Combine

@MainActor
final class RecipeStore: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let categories: [String] = ["All", "Veg", "Non-Veg", "Beef", "Chicken", "Dessert", "Lamb", "Miscellaneous", "Pasta", "Pork", "Seafood", "Side", "Starter", "Vegan", "Breakfast", "Goat"]

    // APIClient is an actor
    private let api = APIClient()

    init() {
        Task { await loadInitial() }
    }

    // switch expression
    func symbol(for category: String) -> String? {
        switch category {
        case "Breakfast": "sunrise.fill"
        case "Chicken": "bird.fill"
        case "Dessert": "cupcake"
        case "Seafood": "fish.fill"
        case "Vegan", "Veg": "leaf.fill"
        case "Non-Veg": "fork.knife"
        case "Pasta": "fork.knife"
        default: "takeoutbag.and.cup.and.straw.fill"
        }
    }

    // split instructions text into steps
    private func splitInstructions(_ text: String) -> [String] {
        // Normalize line endings
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
                              .replacingOccurrences(of: "\r", with: "\n")
                              .trimmingCharacters(in: .whitespacesAndNewlines)

        // Try double-newline (paragraph) split
        var parts = normalized.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // If still one big chunk, try splitting numbered/bulleted patterns
        if parts.count <= 1 {
            // Insert a newline before common numbering markers to create split points
            let patterns = [
                "(?m)\\s*\\d+\\)\\s+",   // 1) 2) etc.
                "(?m)\\s*\\d+\\.\\s+",   // 1. 2. etc.
                "(?m)^-\\s+",            // - bullet at line start
                "(?m)^•\\s+"             // • bullet at line start
            ]

            var working = normalized
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern) {
                    // Prefix matches (except at very start) with a newline to create split points
                    let range = NSRange(location: 0, length: (working as NSString).length)
                    var inserts: [Int] = []
                    regex.enumerateMatches(in: working, options: [], range: range) { match, _, _ in
                        guard let m = match else { return }
                        if m.range.location > 0 {
                            inserts.append(m.range.location)
                        }
                    }
                    // Insert from the end to keep indices valid
                    for idx in inserts.sorted(by: >) {
                        let s = working.index(working.startIndex, offsetBy: idx)
                        working.insert("\n", at: s)
                    }
                }
            }

            // Now split by single newlines
            parts = working.components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        // If still nothing useful, fall back to sentence-ish split
        if parts.count <= 1 {
            // Split on period followed by space for a rough sentence split
            let sentenceSplit = normalized.components(separatedBy: ". ")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { $0.hasSuffix(".") ? $0 : $0 + "." }
            if sentenceSplit.count > 1 {
                parts = sentenceSplit
            }
        }

        return parts
    }

    // Swift 6: catching typed errors from APIClient (throws(APIError))
    func loadInitial(query: String = "") async {
        isLoading = true
        errorMessage = nil
        do {
            let meals = try await api.fetchMeals(query: query)
            self.recipes = meals.map { meal in
                let steps = splitInstructions(meal.strInstructions ?? "")

                return Recipe(
                    title: meal.strMeal,
                    subtitle: meal.strArea ?? (meal.strCategory ?? "Meal"),
                    category: meal.strCategory ?? "Miscellaneous",
                    cookTimeMinutes: Int.random(in: 10...60),
                    calories: Int.random(in: 200...800),
                    rating: Double.random(in: 3.8...5.0),
                    imageURL: URL(string: meal.strMealThumb ?? ""),
                    ingredients: meal.combinedIngredients(),
                    steps: steps.isEmpty ? ["Follow instructions on the recipe page."] : steps
                )
            }
        } catch let apiError as APIError {
            // Avoid relying on APIError.description to prevent compile error if not implemented
            self.errorMessage = String(describing: apiError)
            self.recipes = []
        } catch {
            // Shouldn't happen with typed throws, but kept as safety
            self.errorMessage = error.localizedDescription
            self.recipes = []
        }
        isLoading = false
    }
}
