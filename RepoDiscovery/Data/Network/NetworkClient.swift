//
//  NetworkClient.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import Foundation

// MARK: - Configuration

/// Configuration options for network client behavior.
public struct NetworkConfiguration: Sendable {
    /// The maximum number of times a request should be retried before failing.
    public let maxRetries: Int
    /// The base delay (in seconds) used to calculate exponential backoff between retries.
    public let baseRetryDelay: TimeInterval
    
    public init(maxRetries: Int = 3, baseRetryDelay: TimeInterval = 1.0) {
        self.maxRetries = maxRetries
        self.baseRetryDelay = baseRetryDelay
    }
}

// MARK: - Protocol

/// An abstraction for executing network requests, designed for dependency injection and testability.
public protocol NetworkClient: Sendable {
    /// Executes a network request and decodes the response into the specified type.
    ///
    /// - Parameter request: The `URLRequest` to execute.
    /// - Returns: A decoded instance of type `T`.
    /// - Throws: A `NetworkError` if the transport, validation, or decoding fails.
    func request<T: Decodable>(_ request: URLRequest) async throws -> T
}

// MARK: - Implementation

/// A robust, thread-safe implementation of `NetworkClient` featuring automatic retries and request coalescing.
public final class DefaultNetworkClient: NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let configuration: NetworkConfiguration
    private let taskCoordinator: RequestTaskCoordinator
    
    /// Initializes a new network client.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` used to execute requests. Defaults to `.shared`.
    ///   - decoder: The `JSONDecoder` used to parse responses.
    ///   - configuration: The configuration dictating retry behavior.
    public init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        configuration: NetworkConfiguration = NetworkConfiguration()
    ) {
        self.session = session
        self.decoder = decoder
        self.configuration = configuration
        self.taskCoordinator = RequestTaskCoordinator(session: session, configuration: configuration)
    }
    
    public func request<T: Decodable>(_ request: URLRequest) async throws -> T {
        // 1. Fetch data through the coordinator (handles deduplication and retries)
        let data = try await taskCoordinator.execute(request)
        
        // 2. Decode the result off the network actor
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
}

// MARK: - Request Coordinator (Coalescing & Retries)

/// An actor responsible for managing in-flight network tasks to prevent redundant identical requests.
private actor RequestTaskCoordinator {
    private let session: URLSession
    private let configuration: NetworkConfiguration
    
    /// A dictionary tracking currently executing tasks, keyed by their `URLRequest`.
    private var inFlightTasks: [URLRequest: Task<Data, Error>] = [:]
    
    init(session: URLSession, configuration: NetworkConfiguration) {
        self.session = session
        self.configuration = configuration
    }
    
    /// Executes a request, coalescing duplicates and applying retry logic.
    ///
    /// - Parameter request: The request to execute.
    /// - Returns: The raw response `Data`.
    /// - Throws: A mapped `NetworkError`.
    func execute(_ request: URLRequest) async throws -> Data {
        // If an identical request is already running, await its result instead of starting a new one.
        if let existingTask = inFlightTasks[request] {
            return try await existingTask.value
        }
        
        // Create a new task and store it in the dictionary
        let task = Task {
            defer {
                // Ensure the task is removed from the dictionary once it completes or fails
                inFlightTasks[request] = nil
            }
            return try await performWithRetries(request: request)
        }
        
        inFlightTasks[request] = task
        return try await task.value
    }
    
    /// Executes the raw network call with exponential backoff retry logic.
    private func performWithRetries(request: URLRequest) async throws -> Data {
        var currentAttempt = 0
        
        while true {
            currentAttempt += 1
            
            do {
                let (data, response) = try await session.data(for: request)
                return try validate(response: response, data: data, url: request.url)
                
            } catch {
                // Determine if we should retry based on the attempt count and error type
                let shouldRetry = currentAttempt < configuration.maxRetries && isRetryable(error: error)
                
                guard shouldRetry else {
                    throw error
                }
                
                // Calculate exponential backoff: (baseDelay * 2^attempt) + jitter
                let delaySeconds = configuration.baseRetryDelay * pow(2.0, Double(currentAttempt - 1))
                let jitter = Double.random(in: 0...0.5) // Prevent thundering herd
                let totalDelay = UInt64((delaySeconds + jitter) * 1_000_000_000)
                
                try await Task.sleep(nanoseconds: totalDelay)
            }
        }
    }
    
    /// Validates the HTTP response status code.
    private func validate(response: URLResponse, data: Data, url: URL?) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
                
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 403, 429:
            throw NetworkError.rateLimitExceeded
        default:
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
    }
    
    /// Evaluates whether an error is transient and should be retried.
    private func isRetryable(error: Error) -> Bool {
        // Do not retry decoding errors or explicit rate limits
        if let networkError = error as? NetworkError {
            switch networkError {
            case .rateLimitExceeded, .decodingError, .invalidURL:
                return false
            case .badStatusCode(let code):
                // Retry on server errors (5xx), do not retry client errors (4xx)
                return (500...599).contains(code)
            default:
                break
            }
        }
        
        // Retry standard network connection failures (timeouts, offline, etc.)
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return [
                NSURLErrorTimedOut,
                NSURLErrorCannotFindHost,
                NSURLErrorCannotConnectToHost,
                NSURLErrorNetworkConnectionLost,
                NSURLErrorNotConnectedToInternet
            ].contains(nsError.code)
        }
        
        return false
    }
}
