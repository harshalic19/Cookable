//
//  TagCapsule.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//

import SwiftUI

public struct TagCapsule: View {

    public enum Size {
        case compact
        case regular
        case large

        var paddings: (horizontal: CGFloat, vertical: CGFloat) {
            switch self {
            case .compact: return (10, 6) // match legacy SelectableChip
            case .regular: return (12, 6)
            case .large:   return (14, 8)
            }
        }

        var font: Font {
            switch self {
            case .compact: return .footnote.weight(.semibold)     // match legacy SelectableChip
            case .regular: return .subheadline.weight(.semibold)
            case .large:   return .callout.weight(.semibold)
            }
        }
    }

    public enum ShapeStyle {
        case capsule
        case rounded(cornerRadius: CGFloat)

        @ViewBuilder
        func background<S: SwiftUI.ShapeStyle>(_ fill: S) -> some View {
            switch self {
            case .capsule:
                Capsule().fill(fill)
            case .rounded(let radius):
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(fill)
            }
        }

        @ViewBuilder
        func stroke<S: SwiftUI.ShapeStyle>(_ stroke: S, lineWidth: CGFloat = 1) -> some View {
            switch self {
            case .capsule:
                Capsule().stroke(stroke, lineWidth: lineWidth)
            case .rounded(let radius):
                RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(stroke, lineWidth: lineWidth)
            }
        }
    }

    public enum Style {
        case filledNeutral
        case filledAccent
        case outlinedNeutral
        case outlinedAccent
        case selectableChip
        case custom(foreground: Color, background: Color, border: Color? = nil)

        // Name the tuple elements so we can use colors.fg, colors.bg, colors.border
        func colors(isSelected: Bool, isEnabled: Bool) -> (fg: Color, bg: Color, border: Color?) {
            let disabledOpacity = 0.5

            let base: (fg: Color, bg: Color, border: Color?)
            switch self {
            case .filledNeutral:
                base = (fg: .secondary, bg: Color(.tertiarySystemFill), border: nil)
            case .filledAccent:
                base = (fg: .white.opacity(0.9), bg: Color.accentColor.opacity(0.85), border: nil)
            case .outlinedNeutral:
                base = (fg: .primary, bg: .clear, border: Color.secondary.opacity(0.25))
            case .outlinedAccent:
                base = (fg: .accentColor, bg: .clear, border: Color.accentColor)
            case .selectableChip:
                // Matches legacy SelectableChip look
                let fg: Color = .primary
                let bg: Color = isSelected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground)
                let border: Color = isSelected ? .accentColor : Color.black.opacity(0.08)
                base = (fg: fg, bg: bg, border: border)
            case .custom(let fg, let bg, let border):
                base = (fg: fg, bg: bg, border: border)
            }

            let selected = isSelected ? (fg: base.fg, bg: base.bg.opacity(1.0), border: base.border) : base
            if isEnabled { return selected }
            return (fg: selected.fg.opacity(disabledOpacity),
                    bg: selected.bg.opacity(disabledOpacity),
                    border: selected.border?.opacity(disabledOpacity))
        }
    }

    public let text: String
    public var size: Size
    public var style: Style
    public var shape: ShapeStyle
    public var leadingSystemImage: String?
    public var trailingSystemImage: String?
    public var isSelected: Bool
    public var isEnabled: Bool
    public var accessibilityLabel: String?
    public var onTap: (() -> Void)?

    public init(
        text: String,
        size: Size = .regular,
        style: Style = .filledNeutral,
        shape: ShapeStyle = .capsule,
        leadingSystemImage: String? = nil,
        trailingSystemImage: String? = nil,
        isSelected: Bool = false,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.text = text
        self.size = size
        self.style = style
        self.shape = shape
        self.leadingSystemImage = leadingSystemImage
        self.trailingSystemImage = trailingSystemImage
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.onTap = onTap
    }

    public var body: some View {
        let paddings = size.paddings
        let colors = style.colors(isSelected: isSelected, isEnabled: isEnabled)

        content
            .font(size.font)
            .foregroundStyle(colors.fg)
            .padding(.horizontal, paddings.horizontal)
            .padding(.vertical, paddings.vertical)
            .background(shape.background(colors.bg))
            .overlay {
                if let border = colors.border {
                    shape.stroke(border, lineWidth: 1)
                }
            }
            .opacity(isEnabled ? 1 : 0.8)
            .contentShape(Rectangle())
            .onTapGesture {
                guard isEnabled else { return }
                onTap?()
            }
            .accessibilityLabel(accessibilityLabel ?? text)
            .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var content: some View {
        HStack(spacing: 6) {
            if let leading = leadingSystemImage {
                Image(systemName: leading)
            }
            Text(text)
            if let trailing = trailingSystemImage {
                Image(systemName: trailing)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        TagCapsule(text: "Sugar - 100g")
        TagCapsule(text: "Flour - 200g", style: .outlinedNeutral)
        TagCapsule(text: "Step 1", size: .compact)
        TagCapsule(text: "Favorite", style: .filledAccent, leadingSystemImage: "heart.fill", isSelected: true)
        TagCapsule(text: "Custom", size: .large, style: .custom(foreground: .orange, background: .orange.opacity(0.15), border: .orange), shape: .rounded(cornerRadius: 10))
        TagCapsule(text: "Selectable", size: .compact, style: .selectableChip, leadingSystemImage: "leaf", isSelected: true)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}
