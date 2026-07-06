//
//  SearchRouter.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Observation
import SwiftUI

// MARK: - Route Definitions

/// Defines all possible navigable destinations for Search.
enum SearchRoute: Hashable {
    case detail(RepositoryModel)
    case web(URL)
}

// MARK: - Search Router

@MainActor
@Observable
final class SearchRouter {
    /// The source of truth for the app's navigation stack.
    var path = NavigationPath()

    /// Pushes a new route onto the stack.
    func navigate(to route: SearchRoute) {
        path.append(route)
    }

    /// Pops the top route off the stack.
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    /// Pops all routes, returning to the root view.
    func popToRoot() {
        path.removeLast(path.count)
    }
}
