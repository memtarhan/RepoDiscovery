//
//  MockSearchRepository.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Foundation
@testable import RepoDiscovery

/// A thread-safe mock repository for unit testing.
actor MockSearchRepository: SearchRepository {
    // State is safely protected by the actor
    private(set) var mockResult: Result<[RepositoryModel], Error> = .success([])

    func searchRepositories(query: String) async throws -> [RepositoryModel] {
        switch mockResult {
        case let .success(repositories):
            return repositories
        case let .failure(error):
            throw error
        }
    }

    // Helper function to allow our tests to mutate the result safely
    func updateMockResult(to result: Result<[RepositoryModel], Error>) {
        mockResult = result
    }
}
