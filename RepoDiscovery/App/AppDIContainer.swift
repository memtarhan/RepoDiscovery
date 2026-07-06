//
//  AppDIContainer.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Foundation

/// The Composition Root of the application.
/// Responsible for instantiating and resolving all dependencies.
@MainActor
final class AppDIContainer {
    // Shared instances (Singletons for the lifecycle of the app)
    let networkClient: NetworkClient
    let searchRepository: SearchRepository

    init() {
        // 1. Initialize the lowest-level dependencies first
        // We explicitly configure the advanced network client to handle retries and exponential backoff
        let networkConfig = NetworkConfiguration(maxRetries: 3, baseRetryDelay: 1.0)

        networkClient = DefaultNetworkClient(
            session: .shared,
            decoder: JSONDecoder(),
            configuration: networkConfig
        )

        // 2. Inject them into higher-level services
        searchRepository = DefaultSearchRepository(networkClient: networkClient)
    }

    // MARK: - Factory Methods

    /// Creates a fully injected SearchViewModel
    func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel(repository: searchRepository)
    }
}
