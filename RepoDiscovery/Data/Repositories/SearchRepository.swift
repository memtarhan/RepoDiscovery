//
//  SearchRepository.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Foundation

/// Defines the contract for fetching repositories data with given keyword in title.
protocol SearchRepository {
    /// Searches GitHub for repositories matching the given query.
    /// - Parameter query: The search keyword (e.g., "swift").
    /// - Returns: An array of `Repository` models.
    func searchRepositories(query: String) async throws -> [RepositoryModel]
}

final class DefaultSearchRepository: SearchRepository, Sendable {
    private let networkClient: NetworkClient
    private let baseURL = "https://api.github.com"

    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }

    func searchRepositories(query: String) async throws -> [RepositoryModel] {
        guard var components = URLComponents(string: "\(baseURL)/search/repositories") else {
            throw NetworkError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: query),
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        let response: RepositorySearchDTO = try await networkClient.request(request)

        return response.items.map { mapToDomain($0) }
    }

    private func mapToDomain(_ dto: RepositoryDTO) -> RepositoryModel {
        RepositoryModel(id: dto.id,
                        name: dto.name,
                        description: dto.description,
                        stargazersCount: dto.stargazersCount,
                        forksCount: dto.forksCount,
                        openIssuesCount: dto.openIssuesCount,
                        htmlUrl: URL(string: dto.htmlUrl),
                        owner: RepositoryOwnerModel(login: dto.owner.login,
                                                    avatarUrl: URL(string: dto.owner.avatarUrl)))
    }
}
