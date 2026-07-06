//
//  ShimmerModifier.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

/// An advanced modifier that applies a sweeping gradient mask to simulate a loading shimmer.
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(AnimatedMask(phase: phase))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

struct AnimatedMask: AnimatableModifier {
    var phase: CGFloat = 0

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func body(content: Content) -> some View {
        content.mask(
            GeometryReader { geometry in
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.3), .black, .black.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                // Make the gradient larger than the view so it can sweep across
                .frame(width: geometry.size.width * 3)
                // Calculate the exact offset based on the animation phase
                .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
            }
        )
    }
}

// MARK: - View Extension

extension View {
    /// Applies a premium shimmer loading effect to the view.
    func shimmering() -> some View {
        modifier(Shimmer())
    }
}
