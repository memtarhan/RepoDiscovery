//
//  RepositoryRowSkeleton.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

struct RepositoryRowSkeleton: View {
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
            // Avatar Placeholder using Theme Size and Color
            Circle()
                .fill(AppTheme.Colors.skeletonBase)
                .frame(width: AppTheme.AvatarSize.medium.rawValue, height: AppTheme.AvatarSize.medium.rawValue)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.regular) {
                // Title Placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Colors.skeletonBase)
                    .frame(height: 16)
                    .frame(maxWidth: 180)

                // Description Placeholder (2 lines)
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Colors.skeletonBase)
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)

                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Colors.skeletonBase)
                    .frame(height: 12)
                    .frame(maxWidth: 220)

                // Stats Placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Colors.skeletonBase)
                    .frame(height: 12)
                    .frame(maxWidth: 100)
            }
        }
        .padding(.vertical, AppTheme.Spacing.small)
    }
}
