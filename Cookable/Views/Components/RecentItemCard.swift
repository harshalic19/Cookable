//
//  RecentItemCard.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

struct RecentItemCard: View {
    let item: RecentRecipeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: item.imageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.2))
                        ProgressView()
                    }
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.2))
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    }
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 140, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(item.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            Text(item.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 150)
    }
}
