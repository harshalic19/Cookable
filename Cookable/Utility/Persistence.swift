//
//  Persistence.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import Foundation
import SwiftData

@MainActor
struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema([FavoriteRecipe.self, ShoppingListItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        container = try! ModelContainer(for: schema, configurations: [config])
    }
}
