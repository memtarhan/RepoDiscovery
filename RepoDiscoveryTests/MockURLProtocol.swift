//
//  MockURLProtocol.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Foundation

/// A thread-safe actor to track mock state across concurrent network requests.
actor MockProtocolState {
    static let shared = MockProtocolState()

    var requestCount: Int = 0
    var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    func increment() { requestCount += 1 }
    func getCount() -> Int { requestCount }
    func reset() {
        requestCount = 0
        requestHandler = nil
    }

    func handle(_ request: URLRequest) throws -> (HTTPURLResponse, Data) {
        guard let handler = requestHandler else {
            throw URLError(.badServerResponse)
        }
        return try handler(request)
    }
}

/// Intercepts URLSession traffic to return mocked data and track request execution.
final class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true // Intercept all requests
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        Task {
            await MockProtocolState.shared.increment()

            do {
                let (response, data) = try await MockProtocolState.shared.handle(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }

    override func stopLoading() {
        // Required by protocol, but no action needed for our mock
    }
}
