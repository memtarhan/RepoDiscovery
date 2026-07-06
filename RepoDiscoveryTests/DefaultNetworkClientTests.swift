//
//  DefaultNetworkClientTests.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

@testable import RepoDiscovery
import XCTest

// This prevents the Swift 6 compiler from dragging any inferred MainActor
// isolations from domain models into the test suite.
private struct TestDTO: Codable, Sendable, Equatable {
    let id: Int
}

final class DefaultNetworkClientTests: XCTestCase {
    private var sut: DefaultNetworkClient!

    override func setUp() async throws {
        try await super.setUp()
        await MockProtocolState.shared.reset()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        let testConfig = await NetworkConfiguration(maxRetries: 3, baseRetryDelay: 0.1)
        sut = await DefaultNetworkClient(session: session, configuration: testConfig)
    }

    override func tearDown() async throws {
        sut = nil
        await MockProtocolState.shared.reset()
        try await super.tearDown()
    }

    // MARK: - Coalescing (Deduplication) Tests

    func test_concurrentIdenticalRequests_areCoalescedIntoSingleNetworkCall() async throws {
        // Given
        let expectedId = 999
        let jsonString = """
        { "id": \(expectedId) }
        """

        await MockProtocolState.shared.setHandler { request in
            try await Task.sleep(for: .milliseconds(50))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(jsonString.utf8))
        }

        let request = URLRequest(url: URL(string: "https://api.github.com/test")!)

        // 2. Explicitly capture the SUT locally.
        // This prevents the TaskGroup from implicitly capturing `self` (the test case class),
        // which triggers non-isolated context warnings.
        let localSut = sut!

        // When: We fire 5 concurrent requests using our isolated TestDTO
        let results: [TestDTO] = try await withThrowingTaskGroup(of: TestDTO.self) { group in
            for _ in 0 ..< 5 {
                group.addTask {
                    try await localSut.request(request)
                }
            }

            var collected = [TestDTO]()
            for try await result in group {
                collected.append(result)
            }
            return collected
        }

        // Then
        let actualNetworkCalls = await MockProtocolState.shared.getCount()

        XCTAssertEqual(results.count, 5, "All 5 concurrent callers should receive data.")

        // 3. Extract the value to a local constant before asserting.
        // XCTAssertEqual uses an @autoclosure. In Swift 6, passing an actor-isolated
        // or complex property directly into an autoclosure throws an isolation warning.
        let firstResultId = results.first?.id
        XCTAssertEqual(firstResultId, expectedId)

        XCTAssertEqual(actualNetworkCalls, 1, "The Coordinator failed to coalesce duplicate requests.")
    }

    // MARK: - Retry Logic Tests

    func test_transientServerError_triggersAutomaticRetry() async throws {
        // Given
        let request = URLRequest(url: URL(string: "https://api.github.com/retry")!)
        let string = """
        {"id": 1}
        """
        let expectedData = Data(string.utf8)

        var localExecutionCount = 0

        await MockProtocolState.shared.setHandler { request in
            localExecutionCount += 1
            if localExecutionCount == 1 {
                let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
                return (response, Data())
            } else {
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, expectedData)
            }
        }

        // When: Use the localized TestDTO
        do {
            let _: TestDTO = try await sut.request(request)
        } catch {
            guard case NetworkError.decodingError = error else {
                XCTFail("Expected decoding error after successful retry, got: \(error)")
                return
            }
        }

        // Then
        let totalNetworkCalls = await MockProtocolState.shared.getCount()
        XCTAssertEqual(totalNetworkCalls, 2, "The client should have retried the 500 error exactly once before succeeding.")
    }
}

// Extension to cleanly set the handler
extension MockProtocolState {
    func setHandler(_ handler: @escaping (URLRequest) async throws -> (HTTPURLResponse, Data)) {
        // We wrap the async handler in a synchronous throw to satisfy URLProtocol's flow,
        // managing the suspension inside the URLProtocol's Task block
        requestHandler = { req in
            // This is a simplified bridging mechanism for the mock
            let semaphore = DispatchSemaphore(value: 0)
            var resultData: Data?
            var resultResponse: HTTPURLResponse?
            var resultError: Error?

            Task {
                do {
                    let (res, dat) = try await handler(req)
                    resultResponse = res
                    resultData = dat
                } catch {
                    resultError = error
                }
                semaphore.signal()
            }
            semaphore.wait()

            if let err = resultError { throw err }
            return (resultResponse!, resultData!)
        }
    }
}
