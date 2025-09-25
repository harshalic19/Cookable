//
//  RangeSliderView.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 21/09/25.
//

import SwiftUI

struct RangeSliderView: View {
    @Binding var value: Int
    @Binding var value2: Int
    let bounds: ClosedRange<Int>
    var body: some View {
        HStack {
            Slider(value: Binding(get: { Double(value) }, set: { value = Int($0); if value > value2 { value2 = value } }),
                   in: Double(bounds.lowerBound)...Double(bounds.upperBound))
            Slider(value: Binding(get: { Double(value2) }, set: { value2 = Int($0); if value2 < value { value = value2 } }),
                   in: Double(bounds.lowerBound)...Double(bounds.upperBound))
        }
    }
}
