//
//  RecipeDetailView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: recipe.imageURL) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Rectangle().fill(Color.gray.opacity(0.2))
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                Rectangle().fill(Color.gray.opacity(0.2))
                                Image(systemName: "photo")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.secondary)
                            }
                        @unknown default:
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(height: 260)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.35), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding()
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title)
                        .font(.title.bold())
                    Text(recipe.subtitle)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 14) {
                        Label("\(recipe.cookTimeMinutes) min", systemImage: "clock")
                        Label("\(recipe.calories) cal", systemImage: "flame")
                        Label(String(format: "%.1f", recipe.rating), systemImage: "star.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.headline)

                    TagFlowLayout(recipe.ingredients, spacing: 10) { item in
                        TagCapsule(
                            text: item,
                            size: .regular,
                            style: .filledNeutral,
                            shape: .capsule
                        )
                    }
                }
                .padding(.horizontal)

                if !recipe.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Steps")
                            .font(.headline)
                            .padding(.horizontal)
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 10) {
                                    TagCapsule(
                                        text: "\(index + 1)",
                                        size: .compact,
                                        style: .filledAccent,
                                        shape: .capsule
                                    )
                                    Spacer(minLength: 0)
                                }

                                Text(step.replacingOccurrences(of: "^STEP \\d+\\s*", with: "", options: .regularExpression))
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
                            )
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.top)
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            title: "Preview Meal",
            subtitle: "Area",
            category: "Dessert",
            cookTimeMinutes: 10,
            calories: 280,
            rating: 4.6,
            imageURL: URL(string: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg"),
            ingredients: ["Sugar - 100g", "Flour - 200g"],
            steps: ["Mix ingredients thoroughly.", "Preheat oven to 180°C.", "Bake for 25 minutes.", "Let it cool and serve."]
        ))
    }
    .preferredColorScheme(.dark)
}
