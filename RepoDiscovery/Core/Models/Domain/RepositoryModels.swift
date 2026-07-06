//
//  RepositoryDomainModels.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Foundation

// MARK: - Repository Model

struct RepositoryModel: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let htmlUrl: URL?
    let owner: RepositoryOwnerModel
}

// MARK: - Owner Model

struct RepositoryOwnerModel: Hashable, Sendable {
    let login: String
    let avatarUrl: URL?
}
