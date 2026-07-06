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
        HStack(alignment: .top, spacing: 12) {
            AvatarView(url: repo.owner.avatarUrl, size: 50)

            VStack(alignment: .leading, spacing: 6) {
                Text(repo.name)
                    .font(.headline)

                if let description = repo.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 16) {
                    Label("\(repo.stargazersCount)", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    Label("\(repo.forksCount)", systemImage: "tuningfork")
                        .foregroundColor(.blue)
                }
                .font(.caption)
                .bold()
            }
        }
        .padding(.vertical, 4)
    }
}
