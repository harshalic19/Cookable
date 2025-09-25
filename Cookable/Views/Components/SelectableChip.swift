//
//  SelectableChip.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import SwiftUI

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    var systemImage: String? = nil
    let action: () -> Void

    // Map SelectableChip's look to TagCapsule's .custom style
    private var mappedStyle: TagCapsule.Style {
        if isSelected {
            return .custom(
                foreground: .primary,
                background: Color.accentColor.opacity(0.15),
                border: .accentColor
            )
        } else {
            return .custom(
                foreground: .primary,
                background: Color(.secondarySystemBackground),
                border: Color.black.opacity(0.08)
            )
        }
    }

    var body: some View {
        TagCapsule(
            text: title,
            size: .regular, // closest to the original padding; TagCapsule uses .subheadline weight .semibold
            style: mappedStyle,
            shape: .capsule,
            leadingSystemImage: systemImage,
            isSelected: isSelected,
            isEnabled: true,
            onTap: action
        )
    }
}
