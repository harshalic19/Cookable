//
//  ShoppingListItem.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import Foundation
import SwiftData

@Model
final class ShoppingListItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var isChecked: Bool
    var recipeID: UUID?
    var dateAdded: Date

    init(name: String, isChecked: Bool = false, recipeID: UUID? = nil, dateAdded: Date = .now) {
        self.id = UUID()
        self.name = name
        self.isChecked = isChecked
        self.recipeID = recipeID
        self.dateAdded = dateAdded
    }
}
