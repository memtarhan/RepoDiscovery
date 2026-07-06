//
//  RepositoryDTOs.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Foundation

// MARK: - Search Response

struct RepositorySearchDTO: Codable, Sendable {
    let totalCount: Int
    let items: [RepositoryDTO]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}

// MARK: - Repository Response

struct RepositoryDTO: Codable, Sendable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let htmlUrl: String
    let owner: RepositoryOwnerDTO

    enum CodingKeys: String, CodingKey {
        case id, name, description, owner
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case htmlUrl = "html_url"
    }
}

// MARK: - Owner Response

struct RepositoryOwnerDTO: Codable, Sendable {
    let login: String
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}
