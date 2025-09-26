//
//  ReminderEditor.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 26/09/25.
//

import SwiftUI

struct ReminderEditor: View {
    let reminder: Reminder?
    let onSave: (Reminder) -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var tag: MealTag? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.sentences)
                    DatePicker("When", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Tag") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(MealTag.allCases) { t in
                                TagCapsule(
                                    text: t.rawValue,
                                    size: .compact,
                                    style: .selectableChip,
                                    shape: .capsule,
                                    leadingSystemImage: t.icon,
                                    isSelected: tag == t,
                                    isEnabled: true
                                ) {
                                    withAnimation {
                                        tag = (tag == t) ? nil : t
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(reminder == nil ? "New Reminder" : "Edit Reminder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updated: Reminder
                        if let existing = reminder {
                            updated = Reminder(
                                id: existing.id,
                                title: title,
                                date: date,
                                tag: tag,
                                notificationID: existing.notificationID
                            )
                        } else {
                            updated = Reminder(title: title, date: date, tag: tag)
                        }
                        onSave(updated)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let r = reminder {
                    title = r.title
                    date = r.date
                    tag = r.tag
                }
            }
        }
    }
}
