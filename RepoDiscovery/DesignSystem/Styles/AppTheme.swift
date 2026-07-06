//
//  AppTheme.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

/// The master design system for the application.
enum AppTheme {
    /// Raw color tokens
    enum Colors {
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let brandAccent = Color.blue
        static let background = Color(UIColor.systemBackground)
        static let surface = Color(UIColor.secondarySystemBackground)
    }

    /// Raw typography tokens (Easy to swap to a custom font here later)
    enum Typography {
        static let header = Font.system(.title, design: .rounded).weight(.bold)
        static let subheader = Font.system(.title3, design: .rounded).weight(.semibold)
        static let body = Font.system(.body, design: .default)
        static let caption = Font.system(.caption, design: .default).weight(.medium)
        static let metadata = Font.system(.caption2, design: .monospaced).weight(.bold)
    }

    enum Spacing {
        /// 4 pts - Tight spacing for grouped elements (e.g., Title and Subtitle)
        static let small: CGFloat = 4
        /// 8 pts - Standard spacing between related components
        static let regular: CGFloat = 8
        /// 16 pts - Standard padding for screen edges and major sections
        static let medium: CGFloat = 16
        /// 24 pts - Large spacing to separate distinct conceptual blocks
        static let large: CGFloat = 24
    }
}
