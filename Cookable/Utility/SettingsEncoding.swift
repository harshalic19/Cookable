//
//  SettingsEncoding.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 25/09/25.
//

import Foundation

// Shared helpers for encoding/decoding sets of RawRepresentable items to JSON strings in AppStorage.

func encodeSet<T: RawRepresentable & Codable & Hashable>(_ set: Set<T>) -> String where T.RawValue == String {
    let array = Array(set)
    let data = try? JSONEncoder().encode(array)
    return String(data: data ?? Data("[]".utf8), encoding: .utf8) ?? "[]"
}

func decodeSet<T: RawRepresentable & Codable & Hashable>(from json: String, as type: T.Type) -> Set<T> where T.RawValue == String {
    guard let data = json.data(using: .utf8),
          let array = try? JSONDecoder().decode([T].self, from: data) else { return [] }
    return Set(array)
}
