//
//  SearchView.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @Bindable var viewModel: SearchViewModel
    @Environment(SearchRouter.self) private var router

    var body: some View {
        NavigationStack(path: Bindable(router).path) {
            List {
                switch viewModel.state {
                case .idle:
                    idleView

                case .loading:
                    ForEach(0 ..< 5, id: \.self) { _ in
                        RepositoryRowSkeleton()
                            .shimmering()
                    }
                    .listRowSeparator(.hidden)

                case let .loaded(repositories):
                    ForEach(repositories) { repo in
                        Button(action: {
                            router.navigate(to: .detail(repo))
                        }) {
                            RepositoryRow(repo: repo)
                        }
                        .buttonStyle(.plain)
                    }
                case let .error(message):
                    errorView(message: message)
                }
            }
            .animation(.default, value: viewModel.state)
            .navigationTitle("GitHub Repos")
            .searchable(text: $viewModel.searchText, prompt: "Search e.g., Swift")
            .onChange(of: viewModel.searchText) { _, newValue in
                viewModel.performSearch(query: newValue)
            }
            .refreshable {
                guard !viewModel.searchText.isEmpty else { return }
                viewModel.performSearch(query: viewModel.searchText)
            }
            // Handle Routing Destinations
            .navigationDestination(for: SearchRoute.self) { route in
                switch route {
                case let .detail(repo):
                    DetailsView(repo: repo)
                case let .web(url):
                    WebView(url: url, onFinished: {
                        router.navigateBack()
                    })
                    .ignoresSafeArea()
                    .navigationBarHidden(true)
                }
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

    private func errorView(message: String) -> some View {
        ContentUnavailableView(label: {
            Label("Oops!", systemImage: "exclamationmark.triangle")
        }, description: {
            Text(message)
        }, actions: {
            Button(action: {
                viewModel.performSearch(query: viewModel.searchText)
            }) {
                Text("Try Again")
                    .bold()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 8)
        })
    }
}
