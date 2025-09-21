# Cookable

Cookable is a modern SwiftUI app for iOS that helps you discover, filter, and browse delicious recipes, view details, and get inspired for everyday cooking.

- **Platform:** iOS (SwiftUI, Swift Concurrency, iOS 17+)
- **Minimum Xcode:** 16+ (uses Swift 6 features)
- **Data Source:** TheMealDB (public API, no API key required)

---

## Features

- **Splash screen** with animated vector logo and onboarding message
- **Browse recipes** in an adaptive grid layout
- **Filter by category:** All, Veg, Non-Veg, and more
- **Full-text search** across title, subtitle, and ingredients
- **Recipe details:** Large image, quick facts, ingredients tags, step-by-step instructions
- **Resilient networking:** Error handling and retry for network issues
- **Dark mode** styling by default

---

## Screens

- **SplashView:** Animated logo, onboarding text, and initial data load
- **ContentView:**
  - Header, search bar, horizontally scrollable categories bar
  - Adaptive recipe grid
  - Loading & error states handled gracefully
- **RecipeCardView:** Rich grid cards with images, rating, and quick info
- **RecipeDetailView:** Big header image, metadata, tagged ingredients, and split steps in styled blocks

---

## Architecture & Key Files

- **Views**
  - `SplashView.swift`: Handles splash animation and onboarding
  - `ContentView.swift`: Main screen with search, filter, and grid
  - `RecipeCardView.swift`: Grid item card for each recipe
  - `RecipeDetailView.swift`: Full-screen detailed recipe display
  - `TagCapsule.swift` & `TagFlowLayout.swift`: Custom capsule/tags UI for ingredients and categories

- **Models & Data**
  - `Recipe.swift`: Domain model (`Identifiable`, `Codable`, `Sendable`); used throughout the app
  - `Meal.swift`: Raw DTO model matching TheMealDB structure, with ingredient/measure extraction logic
  - `MealsResponse.swift`: Simple wrapper for array decoding from API

- **State & Networking**
  - `RecipeStore.swift`: Main `ObservableObject` for recipes, loading/error states, categories, and mapping API data to domain recipes. Loads recipes on startup and exposes a category-symbol helper.
  - `APIClient.swift`: Networking logic (async/await, typed throws), fetches and decodes meals, handles errors.

- **Utils**
  - `ReceipeFiltering.swift`: Static `RecipeFiltering` enum for filtering recipes by category and search text.

---

## Data Flow

1. **SplashView** creates and loads a `RecipeStore`, showing onboarding animation.
2. **RecipeStore** automatically loads recipes from TheMealDB with `APIClient`.
3. Meals are mapped into local `Recipe` models (with random cook time/calories/rating for demo purposes).
4. **ContentView** observes `RecipeStore` for updates, loading/error, and user interaction.
5. Filtering and searching is performed locally in-memory using `RecipeFiltering`.

---

## Category Handling

- The `RecipeStore` exposes a fixed list of categories, including “All”, “Veg”, “Non-Veg” (maps to vegan or not), and all primary TheMealDB categories.
- Symbols for each category are provided via `symbol(for:)` for UI display.

---

## UI Details

- **Ingredients** are shown in a responsive tag/capsule layout using custom `TagCapsule` and `TagFlowLayout` views.
- **Steps** are split and styled using robust logic that adapts to newlines, bullet points, numbers, or sentences for clean display.
- All main UI is styled for dark mode by default and uses system-provided backgrounds.

---

## Vector Assets

- The splash logo (`splashLogo`) is a PDF vector asset, sized and clipped responsively.
- Tinting can be enabled via asset catalog ("Template Image") and `.renderingMode(.template)` if desired.

---

## Project Structure

- **CookableApp.swift:** App entry point
- **Views:** `SplashView.swift`, `ContentView.swift`, `RecipeCardView.swift`, `RecipeDetailView.swift`, `TagCapsule.swift`, `TagFlowLayout.swift`
- **Models:** `Recipe.swift`, `Meal.swift`, `MealsResponse.swift`
- **Store:** `RecipeStore.swift`
- **Networking:** `APIClient.swift`
- **Utils:** `ReceipeFiltering.swift`
- **Assets:** `splashLogo.pdf` and recipe images loaded from TheMealDB

---

## Setup & Running

1. Clone this repository.
2. Open `Cookable.xcodeproj` in Xcode 16+.
3. Build and run on any iOS 17+ device or simulator.

No API key is required. The app uses the TheMealDB’s public endpoints.

---

## Filtering Logic

Filtering is performed on device by the static `RecipeFiltering` enum:

```swift
let filtered = RecipeFiltering.filter(
    recipes: allRecipes,
    category: "Veg",
    searchText: "pasta"
)
