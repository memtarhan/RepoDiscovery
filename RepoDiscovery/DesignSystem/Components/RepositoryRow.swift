//
//  RepositoryRow.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

struct RepositoryRow: View {
    let repo: RepositoryModel

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
            AvatarView(url: repo.owner.avatarUrl)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.regular) {
                Text(repo.name)
                    .textStyle(.subheader)

                if let description = repo.description, !description.isEmpty {
                    Text(description)
                        .textStyle(.body)
                        .lineLimit(2)
                }

                HStack(spacing: 16) {
                    Label("\(repo.stargazersCount)", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    Label("\(repo.forksCount)", systemImage: "tuningfork")
                        .foregroundColor(.blue)
                }
                .textStyle(.metadata)
            }
        }
        .padding(.vertical, AppTheme.Spacing.small)
    }
}
