//
//  ImageCacheManager.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import CryptoKit
import UIKit

/// A thread-safe, two-tier image cache optimized for Swift 6 strict concurrency.
actor ImageCacheManager {
    static let shared = ImageCacheManager()

    // Tier 1: Fast Memory Cache
    private let memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 150 // Slightly increased to handle long lists smoothly
        return cache
    }()

    // Tier 2: Persistent Disk Cache
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    // Tracks in-flight downloads to prevent duplicate network calls (Thundering Herd)
    private var activeDownloads: [URL: Task<UIImage?, Error>] = [:]

    private init() {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RepoDiscoveryImageCache")

        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        cacheDirectory = directory
    }

    func getImage(for url: URL) async throws -> UIImage? {
        let cacheKey = generateCacheKey(for: url)

        // 1. Check Memory (Instant)
        if let cachedImage = memoryCache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }

        // 2. Check Disk (Fast)
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey)
        if let diskData = try? Data(contentsOf: fileURL), let diskImage = UIImage(data: diskData) {
            memoryCache.setObject(diskImage, forKey: cacheKey as NSString)
            return diskImage
        }

        // Check In-Flight Downloads (Wait for the existing request if it's already fetching!)
        if let existingTask = activeDownloads[url] {
            return try await existingTask.value
        }

        // 4. Network Fetch (Slow) - Wrap in a task we can track
        let downloadTask = Task<UIImage?, Error> {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200 ... 299).contains(httpResponse.statusCode),
                  let downloadedImage = UIImage(data: data) else {
                return nil
            }

            // Save to Memory & Disk for future
            self.memoryCache.setObject(downloadedImage, forKey: cacheKey as NSString)
            // Writing .atomic tells iOS to write the data to a temporary, hidden file first.
            // Only when the write is 100% complete and verified does it swap it into the actual fileURL location.
            // It eliminates the possibility of corrupted cache files.
            try? data.write(to: fileURL, options: .atomic)

            return downloadedImage
        }

        // Store the active task
        activeDownloads[url] = downloadTask

        // Clean up the dictionary when the task finishes
        defer { activeDownloads[url] = nil }

        // Await and return the result
        return try await downloadTask.value
    }

    // Creates a safe, unique filename using SHA256
    private nonisolated func generateCacheKey(for url: URL) -> String {
        let urlData = Data(url.absoluteString.utf8)
        let hashed = SHA256.hash(data: urlData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
