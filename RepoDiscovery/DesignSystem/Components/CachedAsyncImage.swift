//
//  CachedAsyncImage.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

/// A highly optimized, Swift 6 concurrency-safe Async Image that utilizes a custom caching layer.
@MainActor
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var uiImage: UIImage? = nil
    @State private var isLoading: Bool = false

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        ZStack {
            if let uiImage = uiImage {
                content(Image(uiImage: uiImage))
                    .transition(.opacity)
            } else {
                placeholder()
            }
        }
        // .task(id:) automatically cancels the task if the URL changes (e.g., cell recycling)
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        // Added Task.isCancelled check to abort early if the view is already off-screen
        guard let url = url, uiImage == nil, !isLoading, !Task.isCancelled else { return }

        isLoading = true

        // Fetch through our two-tier caching actor
        if let fetchedImage = try? await ImageCacheManager.shared.getImage(for: url) {
            // Final check: Did the user scroll away while the image was downloading?
            guard !Task.isCancelled else { return }

            withAnimation(.easeIn(duration: 0.2)) {
                self.uiImage = fetchedImage
            }
        }

        isLoading = false
    }
}
