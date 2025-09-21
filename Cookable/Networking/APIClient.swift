//
//  APIClient.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//

import Foundation

struct APIClient {
    // TheMealDB: search all (empty query returns many)
    func fetchMeals(query: String = "") async throws -> [Meal] {
        let base = "https://www.themealdb.com/api/json/v1/1/search.php"
        var comps = URLComponents(string: base)
        comps?.queryItems = [URLQueryItem(name: "s", value: query)]
        guard let url = comps?.url else { throw APIError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.requestFailed(http.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(MealsResponse.self, from: data)
            return decoded.meals ?? []
        } catch {
            throw APIError.decodingFailed
        }
    }
}
