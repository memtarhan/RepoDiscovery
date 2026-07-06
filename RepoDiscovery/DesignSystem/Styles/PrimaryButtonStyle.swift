//
//  PrimaryButtonStyle.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

/// A unified button style that automatically handles theming and press animations.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.subheader)
            .foregroundColor(AppTheme.Colors.background)
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.medium)
            .background(AppTheme.Colors.brandAccent)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
