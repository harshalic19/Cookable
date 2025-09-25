//
//  RecentRecipeItem.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import Foundation

struct RecentRecipeItem: Identifiable, Codable, Hashable {
    var id: UUID
    var recipeID: UUID?
    var title: String
    var subtitle: String
    var imageURL: URL?
    var viewedAt: Date
}
