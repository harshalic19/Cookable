//
//  MealTag.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 26/09/25.
//

import Foundation

enum MealTag: String, CaseIterable, Codable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    case dessert = "Dessert"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch:     return "fork.knife"
        case .dinner:    return "moon.stars.fill"
        case .snack:     return "takeoutbag.and.cup.and.straw.fill"
        case .dessert:   return "cupcake"
        case .other:     return "tag"
        }
    }
}
