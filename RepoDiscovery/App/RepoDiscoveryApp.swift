//
//  RepoDiscoveryApp.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//

import SwiftUI

@main
struct RepoDiscoveryApp: App {
    // 1. Initialize the Router using standard @State for @Observable types
    @State private var router = SearchRouter()

    // 2. Initialize the global DI Container
    @State private var container = AppDIContainer()

    var body: some Scene {
        WindowGroup {
            // 3. Inject the ViewModel via the Factory Method
            SearchView(viewModel: container.makeSearchViewModel())
                // 4. Inject the Router into the environment
                .environment(router)
        }
    }
}
