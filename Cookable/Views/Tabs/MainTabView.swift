//
//  MainTabView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import SwiftUI
import Combine

// Simple router to drive NavigationStack from notifications/deeplinks
final class AppRouter: ObservableObject {
    enum Route: Hashable {
        case recipe(UUID)
    }

    @Published var path = NavigationPath()

    func openRecipe(id: UUID) {
        // Push a new route; you could also reset path if you want a clean stack
        path.append(Route.recipe(id))
    }

    func reset() {
        path = NavigationPath()
    }
}

struct MainTabView: View {
    @EnvironmentObject private var store: RecipeStore
    @StateObject private var router = AppRouter()

    @State private var selectedTab: Int = 0
    private let discoverTabIndex = 0

    var body: some View {
        NavigationStack(path: $router.path) {
            TabView(selection: $selectedTab) {
                DiscoverView()
                    .tabItem { Label("Discover", systemImage: "sparkles") }
                    .tag(0)

                SearchView()
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    .tag(1)

                FavoritesView()
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }
                    .tag(2)

                ShoppingListView()
                    .tabItem { Label("Shopping", systemImage: "cart.fill") }
                    .tag(3)

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                    .tag(4)
            }
            .navigationDestination(for: AppRouter.Route.self) { route in
                switch route {
                case .recipe(let id):
                    RecipeDetailDestination(recipeID: id)
                        .environmentObject(store)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .openRecipeFromNotification)) { note in
                guard let idString = note.userInfo?["recipeID"] as? String,
                      let id = UUID(uuidString: idString) else { return }
                // Optionally switch to a preferred tab before pushing
                selectedTab = discoverTabIndex
                router.openRecipe(id: id)
            }
        }
    }
}

// Wrapper that resolves a Recipe by id from the store and shows the detail.
// If the recipe isn't available yet, you could trigger a fetch by id here.
private struct RecipeDetailDestination: View {
    @EnvironmentObject var store: RecipeStore
    let recipeID: UUID

    var body: some View {
        if let recipe = store.recipes.first(where: { $0.id == recipeID }) {
            RecipeDetailView(recipe: recipe)
        } else {
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading recipe…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                // If you add a fetch-by-id to RecipeStore, call it here.
                // For now, this view will update as soon as the store loads/populates the recipe list.
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
    }
}
