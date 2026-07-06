//
//  SearchViewModelTests.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

@testable import RepoDiscovery
import XCTest

@MainActor
final class SearchViewModelTests: XCTestCase {
    private var sut: SearchViewModel! // System Under Test
    private var mockRepository: MockSearchRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockSearchRepository()
        // Inject the mock into the ViewModel
        sut = SearchViewModel(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - State Tests

    func test_initialState_isIdle() {
        XCTAssertEqual(sut.state, .idle, "The ViewModel should start in the idle state.")
    }

    func test_emptySearch_resetsToIdle() {
        // Given an initial string
        sut.searchText = "Swift"
        sut.performSearch(query: sut.searchText)

        // When searching for an empty or whitespace-only string
        sut.searchText = "   "
        sut.performSearch(query: sut.searchText)

        // Then
        XCTAssertEqual(sut.state, .idle, "An empty search query should instantly reset the state to idle.")
    }

    // MARK: - Concurrency Tests

    func test_successfulSearch_updatesStateToLoaded() async throws {
        // Given
        let mockRepo = RepositoryModel(
            id: 1, name: "Swift", description: "Apple language", stargazersCount: 100,
            forksCount: 10, openIssuesCount: 5, htmlUrl: URL(string: "https://github.com"),
            owner: RepositoryOwnerModel(login: "Apple", avatarUrl: nil)
        )

        // Safely update the actor's mock result
        await mockRepository.updateMockResult(to: .success([mockRepo]))

        // When
        sut.performSearch(query: "Swift")

        // Advance time to allow the 0.5s debounce and network fetch to complete.
        // We wait 0.6 seconds to ensure the task finishes.
        try await Task.sleep(for: .seconds(0.6))

        // Then
        guard case let .loaded(repositories) = sut.state else {
            XCTFail("Expected state to be .loaded, but got \(sut.state)")
            return
        }

        XCTAssertEqual(repositories.count, 1)
        XCTAssertEqual(repositories.first?.name, "Swift")
    }

    func test_failedSearch_updatesStateToError() async throws {
        // Given
        await mockRepository.updateMockResult(to: .failure(NetworkError.rateLimitExceeded))

        // When
        sut.performSearch(query: "Kotlin")

        // Advance time to allow debounce
        try await Task.sleep(for: .seconds(0.6))

        // Then
        guard case let .error(message) = sut.state else {
            XCTFail("Expected state to be .error, but got \(sut.state)")
            return
        }

        XCTAssertEqual(message, NetworkError.rateLimitExceeded.localizedDescription)
    }

    func test_emptyResults_updatesStateToCustomError() async throws {
        // Given a successful API response, but an empty array
        await mockRepository.updateMockResult(to: .success([]))

        // When
        let query = "SomeGibberishQuery"
        sut.performSearch(query: query)

        // Advance time to allow debounce
        try await Task.sleep(for: .seconds(0.6))

        // Then
        guard case let .error(message) = sut.state else {
            XCTFail("Expected state to be .error, but got \(sut.state)")
            return
        }

        XCTAssertTrue(message.contains("No repositories found"), "Expected custom empty state message.")
    }
}
