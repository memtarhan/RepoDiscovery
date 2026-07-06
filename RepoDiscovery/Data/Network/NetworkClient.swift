//
//  NetworkClient.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Foundation

// MARK: - Protocol

/// Abstracts the network layer for dependency injection and mocking.
protocol NetworkClient {
    func request<T: Decodable>(_ request: URLRequest) async throws -> T
}

// MARK: - Implementation

final class DefaultNetworkClient: NetworkClient, Sendable {
    private let session: URLSession
    private let decoder: JSONDecoder

    /// Injecting the session allows for custom URLSession configurations or mocking at the session level if desired.
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200 ... 299:
            // Success - proceed to decode
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error.localizedDescription)
            }

        case 403, 429:
            throw NetworkError.rateLimitExceeded

        default:
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
    }
}
