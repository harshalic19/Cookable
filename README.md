# Cookable

Cookable is a SwiftUI app for iOS and iPadOS that helps you save, organize, and revisit your favorite recipes. Group favorites into custom collections, quickly browse counts, and dive into collection details with a clean, native interface powered by SwiftData.

## Features

- SwiftUI app for iOS/iPadOS with SwiftData persistence
- Discover and search recipes (TheMealDB API)
- Recipe detail: image, meta (time/calories/rating), steps, ingredient tags
- Favorites: save/remove recipes
- Collections: organize favorites into named groups; view counts and details
- Shopping List: add items (manual/from recipe), mark bought, assign to recipe
- Sort shopping list by Recipe, Aisle, or A–Z; hide bought; bulk actions; share
- Profile: Apple/Google sign-in UI, recent history, personalization (diet/allergies)
- Appearance: system/light/dark theme, accent color
- Export data: share favorites and shopping list as text
- Advanced settings: notifications toggle, iCloud Sync toggle (UI only; CloudKit not wired)

## Requirements

- iOS 17.0+ / iPadOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- SwiftData for persistence

## Project Structure (High-Level)

- App / Entry
  - SwiftUI App entry point and root navigation/tab configuration.

- Views
  - SavedCollectionsView: Lists unique collection names derived from favorite recipes. Tapping a collection navigates to a detail view and shows the number of items in each.
  - CollectionDetailView: Displays the recipes/items belonging to a specific collection.

- Models
  - FavoriteRecipe: A SwiftData model representing a saved recipe. Typically includes fields such as title, source/URL, image, notes, and an optional collection string.

- Persistence
  - SwiftData model container and integration via `@Query` and `@Environment(\.modelContext)`.

## Notable Implementation Details

- SwiftUI & SwiftData
  - Uses `@Query` to fetch `FavoriteRecipe` objects directly in views.
  - Derives a unique, sorted list of collection names by trimming whitespace and filtering empty strings.
  - Uses `NavigationLink` to navigate to `CollectionDetailView` for a selected collection.
  - Hides the tab bar on deeper screens via `.toolbar(.hidden, for: .tabBar)`.

- Collections Logic
  - Collection names are computed from favorites where `collection` is non-empty.
  - Per-collection item counts are computed by filtering favorites at render time.

## Screenshots

- Home / Favorites
- Collections list
- Collection detail
- Recipe detail

## Testing

You can use the Swift Testing framework (Swift 5.9+) or XCTest. Example using Swift Testing:

```swift
import Testing

@Suite("Collections Logic")
struct CollectionsTests {
    @Test("Unique collection names are sorted and non-empty")
    func uniqueCollections() async throws {
        let raw = ["Dinner", "  Breakfast  ", "", "dinner", "Lunch"]
        let trimmed = raw.compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let unique = Set(trimmed)
        let sorted = unique.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

        #expect(sorted.first == "Breakfast")
        #expect(sorted.contains("Dinner"))
    }
}
```

## Getting Started

1. Clone the repository:

git clone https://github.com/harshalic19/Cookable.git

cd Cookable

open Cookable.xcodeproj

- If using a workspace:
open Cookable.xcworkspace

3. Select the “Cookable” scheme and a simulator or device.

4. Build and run:
   - Press Cmd+R in Xcode.

Run tests with Cmd+U in Xcode.

## Data & Migrations

- Cookable uses SwiftData for persistence.
- When changing model properties or relationships, consider schema versioning and migrations.
- Test upgrades on devices/simulators with existing data before release.

## Accessibility & Localization

- Uses system fonts and SF Symbols for accessibility and consistency.
- Consider adding localized strings for non-English locales via Localizable.strings.

Roadmap Ideas

- Enhance Profile
- Add Cooking Mode (step-by-step, hands-free)
- Meal Planner (weekly planning + auto shopping list)
- Smart Search (more filters)
- AI Recipe Suggestions (based on ingredients & preferences)
- Nutrition Info & Tracking
- Community Sharing & Collections
- Premium Features (meal planning, offline mode, grocery integration)

## Contributing

Contributions are welcome.
- Open an issue describing your proposal or bug.
- Fork the repo and create a feature branch.
- Submit a pull request with a clear description and screenshots if applicable.

## License

This project is licensed under the MIT License. See LICENSE for details.

## Acknowledgements

- SwiftUI and SwiftData by Apple
- SF Symbols for icons
