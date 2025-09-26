//
// RemindersStore.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 26/09/25.
//

import Foundation
import Combine
import UserNotifications
import SwiftUI

@MainActor
final class RemindersStore: ObservableObject {
    @Published private(set) var reminders: [Reminder] = []

    private let storageKey = "Reminders.Store.JSON"

    init() {
        load()
        // Remove any reminders that are now in the past (already fired)
        pruneExpiredReminders()
        // Additional deep prune for extremely old items if anything slipped through
        pruneOldIfNeeded()
    }

    // Public API

    func add(_ reminder: Reminder) async throws {
        try await scheduleNotification(for: reminder)
        reminders.append(reminder)
        sortAndSave()
    }

    func update(_ reminder: Reminder) async throws {
        await cancelNotification(id: reminder.notificationID)
        try await scheduleNotification(for: reminder, reuseIdentifier: reminder.notificationID)

        if let idx = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[idx] = reminder
            sortAndSave()
        }
    }

    func delete(at offsets: IndexSet) {
        let toDelete = offsets.map { reminders[$0] }
        toDelete.forEach { reminder in
            Task {
                await cancelNotification(id: reminder.notificationID)
            }
        }
        reminders.remove(atOffsets: offsets)
        save()
    }

    func delete(_ reminder: Reminder) {
        if let idx = reminders.firstIndex(of: reminder) {
            delete(at: IndexSet(integer: idx))
        }
    }

    // Remove reminders whose scheduled date is already in the past.
    // Call this on app launch and whenever the app becomes active.
    func pruneExpiredReminders() {
        let now = Date()
        guard !reminders.isEmpty else { return }

        let (expired, upcoming) = reminders.partitioned { $0.date < now }
        if !expired.isEmpty {
            // Clear any delivered/pending notifications for the expired ones
            expired.forEach { rem in
                Task { await cancelNotification(id: rem.notificationID) }
            }
            reminders = upcoming.sorted(by: { $0.date < $1.date })
            save()
        }
    }

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            self.reminders = decoded.sorted(by: { $0.date < $1.date })
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func sortAndSave() {
        reminders.sort(by: { $0.date < $1.date })
        save()
    }

    private func pruneOldIfNeeded() {
        let cutoff = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date.distantPast
        let beforeCount = reminders.count
        reminders.removeAll { $0.date < cutoff }
        if reminders.count != beforeCount {
            save()
        }
    }

    // MARK: - Notifications

    private func ensureAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return
        case .notDetermined:
            let granted = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Bool, Error>) in
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else {
                        cont.resume(returning: granted)
                    }
                }
            }
            if !granted {
                throw NSError(domain: "Reminders", code: 1, userInfo: [NSLocalizedDescriptionKey: "Notifications not authorized"])
            }
        case .denied:
            throw NSError(domain: "Reminders", code: 2, userInfo: [NSLocalizedDescriptionKey: "Notifications denied in Settings"])
        @unknown default:
            return
        }
    }

    private func scheduleNotification(for reminder: Reminder, reuseIdentifier: String? = nil) async throws {
        try await ensureAuthorization()

        let content = UNMutableNotificationContent()
        content.title = reminder.title.isEmpty ? "Cooking Reminder" : reminder.title
        if let tag = reminder.tag {
            content.subtitle = tag.rawValue
        }
        content.sound = .default

        // Pass recipe linkage so tap can open the recipe
        if let recipeID = reminder.linkedRecipeID {
            content.userInfo["recipeID"] = recipeID.uuidString
            // Optional: provide a deeplink string if you register a URL scheme
            content.userInfo["deeplink"] = "cookable://recipe/\(recipeID.uuidString)"
        }

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let identifier = reuseIdentifier ?? reminder.notificationID
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume()
                }
            }
        }
    }

    private func cancelNotification(id: String) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
    }
}

// MARK: - Small helper to partition arrays
private extension Array {
    func partitioned(by belongsInFirstPartition: (Element) throws -> Bool) rethrows -> (first: [Element], second: [Element]) {
        var first: [Element] = []
        var second: [Element] = []
        for element in self {
            if try belongsInFirstPartition(element) {
                first.append(element)
            } else {
                second.append(element)
            }
        }
        return (first, second)
    }
}
