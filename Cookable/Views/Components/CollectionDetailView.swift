//
//  CollectionDetailView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

struct CollectionDetailView: View {
    let name: String
    let items: [FavoriteRecipe]

    var body: some View {
        List {
            ForEach(items) { fav in
                HStack(spacing: 12) {
                    AsyncImage(url: fav.imageURL.flatMap(URL.init(string:))) { phase in
                        switch phase {
                        case .empty:
                            ZStack { Rectangle().fill(Color.gray.opacity(0.2)); ProgressView() }
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            ZStack {
                                Rectangle().fill(Color.gray.opacity(0.2))
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)
                            }
                        @unknown default:
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(width: 72, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    VStack(alignment: .leading) {
                        Text(fav.title).font(.headline).lineLimit(1)
                        Text(fav.subtitle).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(name)
    }
}
