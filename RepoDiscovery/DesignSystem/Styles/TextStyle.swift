//
//  TextStyle.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

// MARK: - Semantic Roles

enum TextStyle {
    /// Used for main screen titles and primary list item names.
    case header
    /// Used for section titles or secondary list information.
    case subheader
    /// Used for long-form text, descriptions, and standard reading.
    case body
    /// Used for hints, timestamps, or secondary descriptive text.
    case caption
    /// Used for highly technical data (e.g., star counts, forks).
    case metadata
}

// MARK: - The Modifier

struct TextStyleModifier: ViewModifier {
    let style: TextStyle

    func body(content: Content) -> some View {
        switch style {
        case .header:
            content
                .font(AppTheme.Typography.header)
                .foregroundColor(AppTheme.Colors.textPrimary)
        case .subheader:
            content
                .font(AppTheme.Typography.subheader)
                .foregroundColor(AppTheme.Colors.textSecondary)
        case .body:
            content
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineSpacing(4) // Bake line spacing directly into the body style
        case .caption:
            content
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
        case .metadata:
            content
                .font(AppTheme.Typography.metadata)
            // We leave the color un-modified here so we can colorize it per view
            // (e.g., making stars yellow, forks blue)
        }
    }
}

// MARK: - The View Extension

extension View {
    /// Applies a unified, semantic text style from the AppTheme.
    func textStyle(_ style: TextStyle) -> some View {
        modifier(TextStyleModifier(style: style))
    }
}
