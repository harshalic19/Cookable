//
//  DietaryPreference.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import Foundation

enum DietaryPreference: String, CaseIterable, Identifiable, Codable, Hashable {
    case Vegetarian, Vegan, GlutenFree = "Gluten-Free", Pescatarian, Keto, Paleo, DairyFree = "Dairy-Free"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .Vegetarian, .Vegan: return "leaf.fill"
        case .GlutenFree: return "g.circle"
        case .Pescatarian: return "fish"
        case .Keto: return "bolt.heart"
        case .Paleo: return "flame"
        case .DairyFree: return "drop.triangle"
        }
    }
}
