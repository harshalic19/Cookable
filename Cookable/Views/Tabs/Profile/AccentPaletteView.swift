//
//  AccentPaletteView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

struct AccentPaletteView: View {
    @Binding var selectedName: String

    private let options = AccentPalette.all

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(28), spacing: 10), count: 8), spacing: 10) {
            ForEach(options, id: \.name) { opt in
                ZStack {
                    Circle()
                        .fill(opt.color.gradient)
                        .frame(width: 26, height: 26)
                        .overlay(
                            Circle().stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                    if selectedName == opt.name {
                        Image(systemName: "checkmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .black.opacity(0.35))
                    }
                }
                .onTapGesture {
                    selectedName = opt.name
                }
                .accessibilityLabel(Text(opt.name))
            }
        }
        .tint(AccentPalette.color(named: selectedName))
    }
}

struct AccentPalette {
    struct Option { let name: String; let color: Color }

    static let all: [Option] = [
        Option(name: "Blue", color: .blue),
        Option(name: "Green", color: .green),
        Option(name: "Orange", color: .orange),
        Option(name: "Pink", color: .pink),
        Option(name: "Purple", color: .purple),
        Option(name: "Red", color: .red),
        Option(name: "Teal", color: .teal),
        Option(name: "Yellow", color: .yellow),
        Option(name: "Indigo", color: .indigo),
        Option(name: "Mint", color: .mint),
        Option(name: "Brown", color: .brown),
        Option(name: "Cyan", color: .cyan)
    ]

    static func color(named: String) -> Color {
        all.first(where: { $0.name == named })?.color ?? .blue
    }
}
