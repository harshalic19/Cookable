//
//  APIError.swift
//  Cookable
//
//  Created by Harshali Chaudhari on 20/09/25.
//
import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed
    case noData
}
