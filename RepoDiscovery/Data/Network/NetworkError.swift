//
//  NetworkError.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case badStatusCode(Int)
    case decodingError(String)
    case rateLimitExceeded
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case let .badStatusCode(code):
            return "The server responded with an error (Status Code: \(code))."
        case let .decodingError(message):
            return "Failed to decode the response: \(message)"
        case .rateLimitExceeded:
            return "GitHub API rate limit exceeded. Please try again later."
        case let .unknown(message):
            return "An unknown error occurred: \(message)"
        }
    }
}
