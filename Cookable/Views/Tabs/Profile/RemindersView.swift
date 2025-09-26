//
//  RemindersView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

struct RemindersView: View {
    @StateObject private var store = RemindersStore()

    // Add/Edit sheet state
    @State private var showingEditor = false
    @State private var editingReminder: Reminder? = nil

    // Quick add inputs
    @State private var reminderDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var reminderText: String = ""
    @State private var selectedTag: MealTag? = nil
    @State private var isSchedulingReminder = false
    @State private var errorMessage: String?

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        List {
            quickAddSection

            if store.reminders.isEmpty {
                emptyState
            } else {
                Section("Upcoming") {
                    ForEach(store.reminders) { reminder in
                        ReminderRow(reminder: reminder)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingReminder = reminder
                                showingEditor = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.delete(reminder)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    editingReminder = reminder
                                    showingEditor = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                    .onDelete(perform: store.delete)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Reminders")
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showingEditor) {
            ReminderEditor(
                reminder: editingReminder,
                onSave: { updated in
                    Task {
                        do {
                            if editingReminder != nil {
                                try await store.update(updated)
                            } else {
                                try await store.add(updated)
                            }
                            await MainActor.run {
                                showingEditor = false
                                editingReminder = nil
                            }
                        } catch {
                            await MainActor.run {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                },
                onCancel: {
                    showingEditor = false
                    editingReminder = nil
                }
            )
        }
        .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
            Button("OK") { errorMessage = nil }
        }, message: {
            Text(errorMessage ?? "")
        })
        .onAppear {
            // Clean up any expired reminders when the view appears
            store.pruneExpiredReminders()
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                // Also clean up when app returns to foreground
                store.pruneExpiredReminders()
            }
        }
    }

    // MARK: - Sections

    private var quickAddSection: some View {
        Section("New Reminder") {
            TextField("Reminder title (e.g., Make lasagna)", text: $reminderText)
                .textInputAutocapitalization(.sentences)

            DatePicker("When", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])

            // Tag chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MealTag.allCases) { tag in
                        TagCapsule(
                            text: tag.rawValue,
                            size: .compact,
                            style: .selectableChip,
                            shape: .capsule,
                            leadingSystemImage: tag.icon,
                            isSelected: selectedTag == tag,
                            isEnabled: true
                        ) {
                            withAnimation {
                                selectedTag = (selectedTag == tag) ? nil : tag
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Button {
                Task { await scheduleQuickReminder() }
            } label: {
                if isSchedulingReminder {
                    ProgressView().frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Label("Schedule Reminder", systemImage: "calendar.badge.clock")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .disabled(reminderText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No reminders yet")
                .font(.headline)
            Text("Add your first reminder above. You can also tag it as Breakfast, Lunch, Dinner, and more.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .listRowBackground(Color.clear)
        .padding(.vertical, 8)
    }

    // MARK: - Helpers

    private func scheduleQuickReminder() async {
        isSchedulingReminder = true
        let new = Reminder(title: reminderText, date: reminderDate, tag: selectedTag)
        do {
            try await store.add(new)
            reminderText = ""
            selectedTag = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isSchedulingReminder = false
    }
}

// MARK: - Row

private struct ReminderRow: View {
    let reminder: Reminder
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Leading icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor.opacity(0.12))
                Image(systemName: "bell.fill")
                    .foregroundStyle(.tint)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(reminder.title.isEmpty ? "Cooking Reminder" : reminder.title)
                        .font(.headline)
                    Spacer()
                }

                Text(dateFormatter.string(from: reminder.date))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let tag = reminder.tag {
                    TagCapsule(
                        text: tag.rawValue,
                        size: .compact,
                        style: .outlinedAccent,
                        shape: .capsule,
                        leadingSystemImage: tag.icon
                    )
                }
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        RemindersView()
    }
}
