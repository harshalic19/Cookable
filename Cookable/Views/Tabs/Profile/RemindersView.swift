//
//  RemindersView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI
import UserNotifications

struct RemindersView: View {
    @State private var reminderDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var reminderText: String = ""
    @State private var isSchedulingReminder = false

    var body: some View {
        Form {
            Section {
                TextField("Reminder title (e.g., Make lasagna)", text: $reminderText)
                    .textInputAutocapitalization(.sentences)
                DatePicker("When", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                Button {
                    scheduleReminder()
                } label: {
                    if isSchedulingReminder {
                        ProgressView().frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Label("Schedule Reminder", systemImage: "calendar.badge.clock")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(reminderText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Reminders")
        .toolbar(.hidden, for: .tabBar)
    }

    private func scheduleReminder() {
        isSchedulingReminder = true
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted { self.addReminderNotification() }
                    DispatchQueue.main.async { self.isSchedulingReminder = false }
                }
            } else if settings.authorizationStatus == .denied {
                DispatchQueue.main.async { self.isSchedulingReminder = false }
            } else {
                self.addReminderNotification()
            }
        }
    }

    private func addReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = reminderText.isEmpty ? "Cooking Reminder" : reminderText
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { _ in
            DispatchQueue.main.async {
                self.isSchedulingReminder = false
                self.reminderText = ""
            }
        }
    }
}
