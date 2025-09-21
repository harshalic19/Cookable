//
//  RecipeCardView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//

import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
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
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", recipe.rating))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                .padding(8)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(8)
            }

            Text(recipe.title)
                .font(.headline)
                .lineLimit(1)

            Text(recipe.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 12) {
                Label("\(recipe.cookTimeMinutes) min", systemImage: "clock")
                Label("\(recipe.calories) cal", systemImage: "flame")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
        )
    }
}

#Preview {
    RecipeCardView(recipe: Recipe(
        title: "Preview Meal",
        subtitle: "Subtitle",
        category: "Dessert",
        cookTimeMinutes: 25,
        calories: 420,
        rating: 4.6,
        imageURL: URL(string: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg"),
        ingredients: ["Sugar - 100g", "Flour - 200g"],
        steps: ["Mix", "Bake"]
    ))
    .padding()
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}

