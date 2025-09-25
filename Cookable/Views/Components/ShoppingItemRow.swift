//
//  ShoppingItemRow.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import SwiftUI

struct ShoppingItemRow: View {
    @Bindable var item: ShoppingListItem

    var body: some View {
        HStack {
            Button(action: { item.isChecked.toggle() }) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isChecked ? .tertiary : .secondary)
            }
            .buttonStyle(.plain)
            Text(item.name)
                .strikethrough(item.isChecked)
            Spacer()
        }
    }
}
