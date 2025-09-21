//
//  Recipe.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//

import Foundation

// Sendable for safe crossing of concurrency domains
struct Recipe: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: String
    let cookTimeMinutes: Int
    let calories: Int
    let rating: Double
    let imageURL: URL?
    let ingredients: [String]
    let steps: [String]

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        category: String,
        cookTimeMinutes: Int,
        calories: Int,
        rating: Double,
        imageURL: URL?,
        ingredients: [String],
        steps: [String]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.cookTimeMinutes = cookTimeMinutes
        self.calories = calories
        self.rating = rating
        self.imageURL = imageURL
        self.ingredients = ingredients
        self.steps = steps
    }
}
