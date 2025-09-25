//
//  Allergy.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import Foundation

enum Allergy: String, CaseIterable, Identifiable, Codable, Hashable {
    case Nuts, Dairy, Shellfish, Soy, Eggs, Wheat, Sesame

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .Nuts: return "leaf"
        case .Dairy: return "drop"
        case .Shellfish: return "tortoise" // placeholder
        case .Soy: return "leaf.circle"
        case .Eggs: return "oval.portrait" // placeholder
        case .Wheat: return "aqi.medium" // placeholder
        case .Sesame: return "circle.hexagongrid" // placeholder
        }
    }

    // Keywords used to detect the allergy in ingredient strings (lowercased).
    var keywords: [String] {
        switch self {
        case .Nuts:
            return [
                "nut", "almond", "peanut", "hazelnut", "walnut", "cashew",
                "pistachio", "pecan", "macadamia", "pine nut", "brazil nut"
            ]
        case .Dairy:
            return [
                "milk", "butter", "cheese", "yoghurt", "yogurt", "cream",
                "ghee", "whey", "casein", "buttermilk", "curd"
            ]
        case .Shellfish:
            return [
                "shrimp", "prawn", "crab", "lobster", "crayfish", "krill",
                "clam", "mussel", "oyster", "scallop", "shellfish"
            ]
        case .Soy:
            return [
                "soy", "soya", "tofu", "edamame", "miso", "tempeh", "tamari", "shoyu", "soy sauce", "soya sauce"
            ]
        case .Eggs:
            return [
                "egg", "albumen", "mayonnaise", "mayo", "meringue"
            ]
        case .Wheat:
            return [
                "wheat", "flour", "semolina", "durum", "farina", "spelt", "couscous", "gluten"
            ]
        case .Sesame:
            return [
                "sesame", "tahini", "benne", "gingelly"
            ]
        }
    }
}

