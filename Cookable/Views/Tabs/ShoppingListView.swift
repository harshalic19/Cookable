//
//  ShoppingListView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @EnvironmentObject var store: RecipeStore
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ShoppingListItem.dateAdded, order: .forward) var items: [ShoppingListItem]

    // Persistent user preferences
    @AppStorage("ShoppingList.SortMode") private var sortModeRaw: String = SortMode.byRecipe.rawValue
    @AppStorage("ShoppingList.HideBought") private var hideBought: Bool = false

    // UI State
    @State private var showingAddSheet = false
    @State private var newItemsText: String = ""
    @State private var newItemRecipeID: UUID? = nil

    @State private var itemToAssign: ShoppingListItem? = nil
    @State private var tempAssignRecipeID: UUID? = nil

    @State private var showVoiceInfo = false

    // MARK: - Types

    enum SortMode: String, CaseIterable, Identifiable {
        case byRecipe = "Recipe"
        case byAisle = "Aisle"
        case alphabetical = "A–Z"

        var id: String { rawValue }
        var title: String { rawValue }
    }

    private var sortMode: SortMode {
        SortMode(rawValue: sortModeRaw) ?? .byRecipe
    }

    // MARK: - Derived Collections

    private var recipeTitlesByID: [UUID: String] {
        Dictionary(uniqueKeysWithValues: store.recipes.map { ($0.id, $0.title) })
    }

    private var filteredItems: [ShoppingListItem] {
        hideBought ? items.filter { !$0.isChecked } : items
    }

    private var groupedByRecipe: [UUID?: [ShoppingListItem]] {
        Dictionary(grouping: filteredItems, by: { $0.recipeID })
    }

    private var sortedRecipeSectionKeys: [UUID?] {
        groupedByRecipe.keys.sorted { lhs, rhs in
            switch (lhs, rhs) {
            case (nil, nil): return false
            case (nil, _): return false // nil last
            case (_, nil): return true
            case (.some(let l), .some(let r)):
                let ln = recipeName(for: l) ?? l.uuidString
                let rn = recipeName(for: r) ?? r.uuidString
                return ln.localizedCaseInsensitiveCompare(rn) == .orderedAscending
            }
        }
    }

    private var groupedByAisle: [String: [ShoppingListItem]] {
        Dictionary(grouping: filteredItems, by: { aisle(for: $0.name) })
    }

    private var sortedAisleKeys: [String] {
        groupedByAisle.keys.sorted { a, b in
            if a == "Other" { return false }
            if b == "Other" { return true }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }
    }

    private var groupedAlphabetical: [String: [ShoppingListItem]] {
        Dictionary(grouping: filteredItems, by: { firstLetterGroup(for: $0.name) })
    }

    private var sortedAlphaKeys: [String] {
        groupedAlphabetical.keys.sorted { a, b in
            if a == "#" { return false }
            if b == "#" { return true }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                // Controls
                VStack(spacing: 8) {
                    Picker("Sort", selection: $sortModeRaw) {
                        ForEach(SortMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    Toggle("Hide bought items", isOn: $hideBought)
                        .padding(.horizontal)
                }

                if filteredItems.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "Shopping List is empty",
                        systemImage: "cart",
                        description: Text("Add ingredients from a recipe or tap + to add items manually.")
                    )
                    Spacer()
                } else {
                    listContent
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    CButton(icon: "mic", kind: .plain, accessibilityLabel: "Voice Add") { showVoiceInfo = true }
                    ShareLink(item: shareText) { Image(systemName: "square.and.arrow.up") }
                    Menu {
                        Button("Mark all as bought", systemImage: "checkmark.circle") { markAll(bought: true) }
                        Button("Unmark all", systemImage: "circle") { markAll(bought: false) }
                        Divider()
                        Button("Remove bought items", systemImage: "trash.circle") { removeBoughtItems() }
                        Button("Clear list", systemImage: "trash", role: .destructive) { clearAll() }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    CButton(icon: "plus", kind: .plain, accessibilityLabel: "Add Items") { newItemsText = ""; newItemRecipeID = nil; showingAddSheet = true }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddItemsSheet(
                    recipes: store.recipes,
                    text: $newItemsText,
                    selectedRecipeID: $newItemRecipeID,
                    onAdd: addItemsFromText
                )
                .presentationDetents([.height(320), .medium])
            }
            .sheet(item: $itemToAssign) { item in
                AssignRecipeSheet(
                    itemName: item.name,
                    recipes: store.recipes,
                    selectedRecipeID: Binding(
                        get: { tempAssignRecipeID ?? item.recipeID },
                        set: { tempAssignRecipeID = $0 }
                    ),
                    onAssign: {
                        item.recipeID = tempAssignRecipeID
                        tempAssignRecipeID = nil
                    }
                )
                .presentationDetents([.height(280), .medium])
            }
            .alert("Voice Add", isPresented: $showVoiceInfo, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text("Use the microphone key on the keyboard to dictate items, or set up a Siri Shortcut in a future update. For now, tap + to add items.")
            })
        }
    }

    @ViewBuilder
    private var listContent: some View {
        switch sortMode {
        case .byRecipe:
            List {
                ForEach(sortedRecipeSectionKeys, id: \.self) { rid in
                    Section(header: Text(rid.flatMap { recipeName(for: $0) } ?? "Other")) {
                        ForEach(groupedByRecipe[rid] ?? []) { item in
                            row(for: item)
                        }
                        .onDelete { offsets in
                            delete(items: groupedByRecipe[rid] ?? [], at: offsets)
                        }
                    }
                }
            }

        case .byAisle:
            List {
                ForEach(sortedAisleKeys, id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(groupedByAisle[key] ?? []) { item in
                            row(for: item)
                        }
                        .onDelete { offsets in
                            delete(items: groupedByAisle[key] ?? [], at: offsets)
                        }
                    }
                }
            }

        case .alphabetical:
            List {
                ForEach(sortedAlphaKeys, id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach((groupedAlphabetical[key] ?? []).sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { item in
                            row(for: item)
                        }
                        .onDelete { offsets in
                            delete(items: groupedAlphabetical[key] ?? [], at: offsets)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Row

    private func row(for item: ShoppingListItem) -> some View {
        ShoppingItemRow(item: item)
            .foregroundStyle(item.isChecked ? Color.green : Color.primary)
            .contentShape(Rectangle())
            .onTapGesture {
                item.isChecked.toggle()
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    if let context = item.modelContext {
                        context.delete(item)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    item.isChecked.toggle()
                } label: {
                    if item.isChecked {
                        Label("Unbuy", systemImage: "arrow.uturn.left.circle")
                    } else {
                        Label("Bought", systemImage: "checkmark.circle.fill")
                    }
                }
                .tint(item.isChecked ? .gray : .green)

                Button {
                    itemToAssign = item
                    tempAssignRecipeID = item.recipeID
                } label: {
                    Label("Assign", systemImage: "text.badge.plus")
                }
                .tint(.blue)
            }
    }

    // MARK: - Helpers

    private func recipeName(for id: UUID) -> String? {
        recipeTitlesByID[id]
    }

    private func aisle(for name: String) -> String {
        let lower = name.lowercased()

        let produce = ["apple", "banana", "orange", "lemon", "lime", "onion", "garlic", "tomato", "lettuce", "spinach", "carrot", "potato", "pepper", "cucumber", "broccoli", "herb", "cilantro", "parsley"]
        let dairy = ["milk", "cheese", "butter", "yogurt", "cream", "egg"]
        let meat = ["chicken", "beef", "pork", "lamb", "bacon", "ham", "turkey", "sausage"]
        let bakery = ["bread", "bun", "bagel", "tortilla", "pita"]
        let pantry = ["rice", "pasta", "noodle", "flour", "sugar", "salt", "oil", "vinegar", "honey"]
        let spices = ["pepper", "cumin", "paprika", "turmeric", "chili", "oregano", "basil", "cinnamon", "spice"]
        let beverages = ["water", "juice", "soda", "coffee", "tea"]
        let frozen = ["frozen", "ice cream", "peas", "corn"]
        let canned = ["canned", "bean", "tomato paste", "coconut milk", "broth", "stock"]
        let condiments = ["ketchup", "mustard", "mayo", "mayonnaise", "soy sauce", "hot sauce"]
        let baking = ["yeast", "baking powder", "baking soda", "cocoa", "chocolate chip", "vanilla"]

        func containsAny(_ words: [String]) -> Bool { words.contains { lower.contains($0) } }

        if containsAny(produce) { return "Produce" }
        if containsAny(dairy) { return "Dairy" }
        if containsAny(meat) { return "Meat" }
        if containsAny(bakery) { return "Bakery" }
        if containsAny(spices) { return "Spices" }
        if containsAny(condiments) { return "Condiments" }
        if containsAny(baking) { return "Baking" }
        if containsAny(canned) { return "Canned & Jars" }
        if containsAny(frozen) { return "Frozen" }
        if containsAny(beverages) { return "Beverages" }
        if containsAny(pantry) { return "Pantry" }
        return "Other"
    }

    private func firstLetterGroup(for name: String) -> String {
        guard let first = name.trimmingCharacters(in: .whitespacesAndNewlines).first else { return "#" }
        let s = String(first).uppercased()
        return s.rangeOfCharacter(from: CharacterSet.letters) != nil ? s : "#"
    }

    private var shareText: String {
        let all = items
        if all.isEmpty { return "Shopping List is empty." }

        switch sortMode {
        case .byRecipe:
            var lines: [String] = []
            for key in sortedRecipeSectionKeys {
                let title = key.flatMap { recipeName(for: $0) } ?? "Other"
                lines.append("• \(title):")
                for i in (groupedByRecipe[key] ?? []) {
                    lines.append("  - \(i.name)\(i.isChecked ? " ✅" : "")")
                }
            }
            return lines.joined(separator: "\n")

        case .byAisle:
            var lines: [String] = []
            for key in sortedAisleKeys {
                lines.append("• \(key):")
                for i in (groupedByAisle[key] ?? []) {
                    lines.append("  - \(i.name)\(i.isChecked ? " ✅" : "")")
                }
            }
            return lines.joined(separator: "\n")

        case .alphabetical:
            let sorted = all.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            return sorted.map { "\($0.name)\($0.isChecked ? " ✅" : "")" }.joined(separator: "\n")
        }
    }

    // MARK: - Actions

    private func addItemsFromText() {
        let separators = CharacterSet(charactersIn: ",\n")
        let parts = newItemsText
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !parts.isEmpty else { return }

        for name in parts {
            let exists = items.contains {
                $0.name.compare(name, options: .caseInsensitive) == .orderedSame &&
                $0.recipeID == newItemRecipeID
            }
            if !exists {
                let item = ShoppingListItem(
                    name: name,
                    isChecked: false,
                    recipeID: newItemRecipeID,
                    dateAdded: .now
                )
                modelContext.insert(item)
            }
        }

        showingAddSheet = false
        newItemsText = ""
        newItemRecipeID = nil
    }

    private func markAll(bought: Bool) {
        for item in items {
            item.isChecked = bought
        }
    }

    private func removeBoughtItems() {
        for item in items where item.isChecked {
            if let context = item.modelContext {
                context.delete(item)
            }
        }
    }

    private func clearAll() {
        for item in items {
            if let context = item.modelContext {
                context.delete(item)
            }
        }
    }

    private func delete(items: [ShoppingListItem], at offsets: IndexSet) {
        for idx in offsets {
            let item = items[idx]
            if let context = item.modelContext {
                context.delete(item)
            }
        }
    }
}

// MARK: - Add Items Sheet

private struct AddItemsSheet: View {
    let recipes: [Recipe]
    @Binding var text: String
    @Binding var selectedRecipeID: UUID?
    var onAdd: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Items") {
                    TextEditor(text: $text)
                        .frame(minHeight: 100)
                        .font(.body)
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled(false)
                    Text("Separate items with commas or new lines.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Assign to Recipe (optional)") {
                    Picker("Recipe", selection: $selectedRecipeID) {
                        Text("None").tag(UUID?.none)
                        ForEach(recipes) { r in
                            Text(r.title).tag(Optional(r.id))
                        }
                    }
                }
            }
            .navigationTitle("Add Items")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CButton(title: "Cancel", kind: .plain) { text = ""; selectedRecipeID = nil; dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CButton(title: "Add", kind: .primary, isEnabled: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) { onAdd() }
                }
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
}

// MARK: - Assign Recipe Sheet

private struct AssignRecipeSheet: View {
    let itemName: String
    let recipes: [Recipe]
    @Binding var selectedRecipeID: UUID?
    var onAssign: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    Text(itemName)
                }
                Section("Assign to Recipe") {
                    Picker("Recipe", selection: $selectedRecipeID) {
                        Text("None").tag(UUID?.none)
                        ForEach(recipes) { r in
                            Text(r.title).tag(Optional(r.id))
                        }
                    }
                }
            }
            .navigationTitle("Assign Recipe")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CButton(title: "Cancel", kind: .plain) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CButton(title: "Done", kind: .primary) { onAssign(); dismiss() }
                }
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
}
