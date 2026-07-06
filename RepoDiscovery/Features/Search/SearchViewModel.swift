//
//  SearchViewModel.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Foundation
import Observation

enum SearchViewState: Equatable {
    case idle
    case loading
    case loaded([RepositoryModel])
    case error(String)

    // Conforming to Equatable helps SwiftUI avoid unnecessary redraws
    static func == (lhs: SearchViewState, rhs: SearchViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading): return true
        case let (.loaded(l), .loaded(r)): return l == r
        case let (.error(l), .error(r)): return l == r
        default: return false
        }
    }
}

@MainActor
@Observable
final class SearchViewModel {
    var searchText: String = ""
    private(set) var state: SearchViewState = .idle

    private let repository: SearchRepository
    private var searchTask: Task<Void, Never>?

    init(repository: SearchRepository) {
        self.repository = repository
    }

    func performSearch(query: String) {
        // 1. Cancel any in-flight search task immediately
        searchTask?.cancel()

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // 2. Handle empty state
        guard !trimmedQuery.isEmpty else {
            state = .idle
            return
        }

        // 3. Spin up a new concurrent task
        state = .loading

        // 4. Spin up a new concurrent task
        searchTask = Task {
            do {
                // Debounce: Wait 0.5 seconds before hitting the network
                try await Task.sleep(nanoseconds: 500000000)

                // If the user typed/deleted another letter during that 0.5s, this task was cancelled.
                guard !Task.isCancelled else { return }

                let results = try await repository.searchRepositories(query: trimmedQuery)

                guard !Task.isCancelled else { return }

                // Update state
                state = results.isEmpty ? .error("No repositories found for '\(trimmedQuery)'.") : .loaded(results)

            } catch {
                guard !Task.isCancelled else { return }

                if let networkError = error as? NetworkError {
                    state = .error(networkError.localizedDescription)
                } else {
                    state = .error(error.localizedDescription)
                }
            }
        }
    }
}
