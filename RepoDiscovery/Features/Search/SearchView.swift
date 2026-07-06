//
//  SearchView.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            List {
                switch viewModel.state {
                case .idle:
                    idleView
                case .loading:
                    loadingView
                case let .loaded(repositories):
                    ForEach(repositories) { repo in
                        NavigationLink(value: repo) {
                            RepositoryRow(repo: repo)
                        }
                    }
                case let .error(message):
                    errorView(message: message)
                }
            }
            .navigationTitle("GitHub Repos")
            .searchable(text: $viewModel.searchText, prompt: "Search e.g., Swift")
            // Trigger search when user types (debounced in the ViewModel)
            .onChange(of: viewModel.searchText) { _, newValue in
                viewModel.performSearch(query: newValue)
            }
            // Native Pull-to-Refresh
            .refreshable {
                guard !viewModel.searchText.isEmpty else { return }
                viewModel.performSearch(query: viewModel.searchText)
            }
            .navigationDestination(for: RepositoryModel.self) { repo in
                DetailsView(repo: repo)
            }
        }
    }

    // MARK: - Subviews

    private var idleView: some View {
        ContentUnavailableView(
            "Search GitHub",
            systemImage: "magnifyingglass",
            description: Text("Find repositories, projects, and more.")
        )
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView("Searching...")
                .padding()
            Spacer()
        }
        .listRowBackground(Color.clear)
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView(
            "Oops!",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }
}
