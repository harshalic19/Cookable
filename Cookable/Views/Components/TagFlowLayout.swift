//
//  TagFlowLayout.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//
import SwiftUI

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct TagFlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    var data: Data
    var spacing: CGFloat
    var rowSpacing: CGFloat
    var content: (Data.Element) -> Content

    @State private var availableWidth: CGFloat = 0
    @State private var measuredHeight: CGFloat = 0

    init(
        _ data: Data,
        spacing: CGFloat = 8,
        rowSpacing: CGFloat? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.rowSpacing = rowSpacing ?? spacing
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if availableWidth > 0 {
                let rows = makeRows(availableWidth: availableWidth, spacing: spacing)
                VStack(alignment: .leading, spacing: rowSpacing) {
                    ForEach(rows.indices, id: \.self) { rowIndex in
                        HStack(spacing: spacing) {
                            ForEach(rows[rowIndex], id: \.self) { element in
                                content(element)
                            }
                        }
                    }
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: HeightPreferenceKey.self, value: proxy.size.height)
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: measuredHeight > 0 ? measuredHeight : nil) // reserve vertical space
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            // Update once the internal stack has a concrete height
            if measuredHeight != height {
                measuredHeight = height
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { availableWidth = proxy.size.width }
                    .onChange(of: proxy.size.width) { _, newWidth in
                        if availableWidth != newWidth {
                            availableWidth = newWidth
                        }
                    }
            }
        )
    }

    private func makeRows(availableWidth: CGFloat, spacing: CGFloat) -> [[Data.Element]] {
        guard availableWidth > 0 else { return [Array(data)] }

        var rows: [[Data.Element]] = [[]]
        var currentRowWidth: CGFloat = 0

        let measurementCache = MeasurementCache<Data.Element>(content: content)

        for element in data {
            let size = measurementCache.size(for: element)
            let itemWidth = size.width

            let proposedWidth = (rows.last!.isEmpty ? 0 : currentRowWidth + spacing) + itemWidth

            if proposedWidth <= availableWidth {
                rows[rows.count - 1].append(element)
                currentRowWidth = proposedWidth
            } else {
                rows.append([element])
                currentRowWidth = itemWidth
            }
        }

        if rows.last?.isEmpty == true { _ = rows.popLast() }
        return rows
    }
}

// Simple measurement cache to avoid repeatedly sizing identical views
private final class MeasurementCache<Item: Hashable> {
    private var cache: [Item: CGSize] = [:]
    private let content: (Item) -> any View

    init<Content: View>(content: @escaping (Item) -> Content) {
        self.content = content
    }

    func size(for item: Item) -> CGSize {
        if let cached = cache[item] { return cached }
        let size = measure(content(item))
        cache[item] = size
        return size
    }

    private func measure<V: View>(_ view: V) -> CGSize {
        #if os(iOS)
        let controller = UIHostingController(rootView: view.fixedSize())
        let target = CGSize(width: UIView.layoutFittingCompressedSize.width,
                            height: UIView.layoutFittingCompressedSize.height)
        let size = controller.sizeThatFits(in: target)
        return size
        #else
        let controller = NSHostingController(rootView: view.fixedSize())
        let size = controller.view.fittingSize
        return size
        #endif
    }
}
