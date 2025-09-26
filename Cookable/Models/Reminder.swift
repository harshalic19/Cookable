//
// Reminder.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 26/09/25.
//

import Foundation

struct Reminder: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var date: Date
    var tag: MealTag?
    var notificationID: String

    // Link back to a recipe so tapping the notification can open it
    var linkedRecipeID: UUID?

    init(id: UUID = UUID(),
         title: String,
         date: Date,
         tag: MealTag? = nil,
         notificationID: String = UUID().uuidString,
         linkedRecipeID: UUID? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.tag = tag
        self.notificationID = notificationID
        self.linkedRecipeID = linkedRecipeID
    }
}

