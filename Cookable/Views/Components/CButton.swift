//
//  CButton.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

struct CButton: View {

    enum Kind {
        case primary
        case secondary
        case tinted
        case outlined
        case destructive
        case plain
    }

    enum Size {
        case compact
        case regular
        case large

        var paddings: (horizontal: CGFloat, vertical: CGFloat) {
            switch self {
            case .compact: return (12, 8)
            case .regular: return (16, 10)
            case .large:   return (20, 14)
            }
        }

        var font: Font {
            switch self {
            case .compact: return .subheadline.weight(.semibold)
            case .regular: return .callout.weight(.semibold)
            case .large:   return .body.weight(.semibold)
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .compact: return 12
            case .regular: return 14
            case .large:   return 16
            }
        }
    }

    enum ShapeStyle {
        case capsule
        case rounded(cornerRadius: CGFloat?)
    }

    var title: String?
    var systemImage: String?
    var kind: Kind
    var size: Size
    var shape: ShapeStyle
    var fullWidth: Bool
    var isLoading: Bool
    var isEnabled: Bool
    var fontOverride: Font?
    var tint: Color?
    var accessibilityLabel: String?
    var accessibilityHint: String?

    private let actionAsync: (() async -> Void)?

    init(
        title: String,
        systemImage: String? = nil,
        kind: Kind = .primary,
        size: Size = .regular,
        shape: ShapeStyle = .rounded(cornerRadius: nil),
        fullWidth: Bool = false,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        font: Font? = nil,
        tint: Color? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.kind = kind
        self.size = size
        self.shape = shape
        self.fullWidth = fullWidth
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.fontOverride = font
        self.tint = tint
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.actionAsync = { action() }
    }

    init(
        title: String,
        systemImage: String? = nil,
        kind: Kind = .primary,
        size: Size = .regular,
        shape: ShapeStyle = .rounded(cornerRadius: nil),
        fullWidth: Bool = false,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        font: Font? = nil,
        tint: Color? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () async -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.kind = kind
        self.size = size
        self.shape = shape
        self.fullWidth = fullWidth
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.fontOverride = font
        self.tint = tint
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.actionAsync = action
    }

    init(
        icon: String,
        kind: Kind = .plain,
        size: Size = .regular,
        shape: ShapeStyle = .rounded(cornerRadius: nil),
        isLoading: Bool = false,
        isEnabled: Bool = true,
        font: Font? = nil,
        tint: Color? = nil,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = nil
        self.systemImage = icon
        self.kind = kind
        self.size = size
        self.shape = shape
        self.fullWidth = false
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.fontOverride = font
        self.tint = tint
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.actionAsync = { action() }
    }

    init(
        icon: String,
        kind: Kind = .plain,
        size: Size = .regular,
        shape: ShapeStyle = .rounded(cornerRadius: nil),
        isLoading: Bool = false,
        isEnabled: Bool = true,
        font: Font? = nil,
        tint: Color? = nil,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        action: @escaping () async -> Void
    ) {
        self.title = nil
        self.systemImage = icon
        self.kind = kind
        self.size = size
        self.shape = shape
        self.fullWidth = false
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.fontOverride = font
        self.tint = tint
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.actionAsync = action
    }

    @State private var performing = false
    @Environment(\.isEnabled) private var envEnabled

    var body: some View {
        let effectiveEnabled = envEnabled && isEnabled && !performing && !isLoading
        let scheme = colorScheme(kind: kind, enabled: effectiveEnabled)
        let paddings = size.paddings
        let fontToUse = fontOverride ?? size.font
        let foreground = tint ?? scheme.fg

        Button {
            Task {
                guard effectiveEnabled, let actionAsync else { return }
                performing = true
                await actionAsync()
                performing = false
            }
        } label: {
            ZStack {
                labelContent.opacity(performing || isLoading ? 0 : 1)
                if performing || isLoading {
                    ProgressView().progressViewStyle(.circular).tint(scheme.spinner)
                }
            }
            .font(fontToUse)
            .foregroundStyle(foreground)
            .padding(.horizontal, paddings.horizontal)
            .padding(.vertical, paddings.vertical)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(backgroundView(color: scheme.bg))
            .overlay(borderView(color: scheme.border))
            .opacity(effectiveEnabled ? 1.0 : 0.6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel ?? title ?? "")
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(performing || isLoading ? Text("Loading") : Text(""))
        .disabled(!effectiveEnabled)
    }

    @ViewBuilder
    private var labelContent: some View {
        if let title {
            HStack(spacing: 8) {
                if let icon = systemImage { Image(systemName: icon) }
                Text(title)
            }
        } else if let icon = systemImage {
            Image(systemName: icon)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func backgroundView(color: Color?) -> some View {
        if kind == .plain {
            Color.clear
        } else {
            switch shape {
            case .capsule:
                Capsule(style: .continuous).fill(color ?? .clear)
            case .rounded(let radius):
                RoundedRectangle(cornerRadius: radius ?? size.cornerRadius, style: .continuous)
                    .fill(color ?? .clear)
            }
        }
    }

    @ViewBuilder
    private func borderView(color: Color?) -> some View {
        if kind != .plain, let color {
            switch shape {
            case .capsule:
                Capsule(style: .continuous).stroke(color, lineWidth: 1)
            case .rounded(let radius):
                RoundedRectangle(cornerRadius: radius ?? size.cornerRadius, style: .continuous)
                    .stroke(color, lineWidth: 1)
            }
        } else {
            EmptyView()
        }
    }

    private struct Scheme { let fg: Color; let bg: Color?; let border: Color?; let spinner: Color }

    private func colorScheme(kind: Kind, enabled: Bool) -> Scheme {
        let alpha: Double = enabled ? 1.0 : 0.5
        switch kind {
        case .primary:     return .init(fg: .white.opacity(alpha), bg: .accentColor.opacity(alpha), border: nil, spinner: .white)
        case .secondary:   return .init(fg: .primary.opacity(alpha), bg: Color(.tertiarySystemFill).opacity(alpha), border: nil, spinner: .primary)
        case .tinted:      return .init(fg: .accentColor.opacity(alpha), bg: .accentColor.opacity(0.12 * alpha), border: .accentColor.opacity(0.9 * alpha), spinner: .accentColor)
        case .outlined:    return .init(fg: .primary.opacity(alpha), bg: nil, border: .secondary.opacity(0.35 * alpha), spinner: .primary)
        case .destructive: return .init(fg: .white.opacity(alpha), bg: .red.opacity(alpha), border: nil, spinner: .white)
        case .plain:       return .init(fg: .accentColor.opacity(alpha), bg: nil, border: nil, spinner: .accentColor)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        CButton(title: "Primary", kind: .primary, fullWidth: true) {}
        CButton(title: "Secondary", systemImage: "cart", kind: .secondary) {}
        CButton(title: "Tinted", systemImage: "star.fill", kind: .tinted) {}
        CButton(title: "Outlined", systemImage: "square.and.arrow.up", kind: .outlined) {}
        CButton(title: "Destructive", systemImage: "trash", kind: .destructive) {}
        CButton(title: "Plain Link", systemImage: "link", kind: .plain) {}
        CButton(title: "Async Action", kind: .tinted) { try? await Task.sleep(nanoseconds: 300_000_000) }
        HStack {
            CButton(title: "Small", kind: .outlined, size: .compact) {}
            CButton(title: "Large", kind: .secondary, size: .large, shape: .capsule) {}
        }
        HStack {
            CButton(icon: "chevron.left", size: .compact, accessibilityLabel: "Back") {}
            CButton(icon: "heart.fill", size: .regular, tint: .red, accessibilityLabel: "Favorite") {}
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}
