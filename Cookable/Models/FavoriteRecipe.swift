//
//  FavoriteRecipe.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import Foundation
import SwiftData

@Model
final class FavoriteRecipe: Identifiable {
    @Attribute(.unique) var id: UUID
    var recipeID: UUID
    var title: String
    var subtitle: String
    var category: String
    var imageURL: String?
    var collection: String?
    var dateAdded: Date

    init(recipeID: UUID, title: String, subtitle: String, category: String, imageURL: String?, collection: String? = nil, dateAdded: Date = .now) {
        self.id = UUID()
        self.recipeID = recipeID
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.imageURL = imageURL
        self.collection = collection
        self.dateAdded = dateAdded
    }
}
