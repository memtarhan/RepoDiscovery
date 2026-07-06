//
//  DetailsView.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

struct DetailsView: View {
    let repo: RepositoryModel
    @Environment(SearchRouter.self) private var router

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                headerSection
                statsSection
                if let description = repo.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .textStyle(.subheader)

                        Text(description)
                            .textStyle(.body)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(AppTheme.Spacing.medium)
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if let url = repo.htmlUrl {
                Button(action: {
                    router.navigate(to: .web(url))
                }) {
                    Label("Open in Safari", systemImage: "safari")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.bottom, AppTheme.Spacing.regular)
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(spacing: 16) {
            AvatarView(url: repo.owner.avatarUrl, size: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text(repo.name)
                    .textStyle(.header)

                Text(repo.owner.login)
                    .textStyle(.subheader)
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(title: "Stars", value: repo.stargazersCount, icon: "star.fill", color: .yellow)
            StatCard(title: "Forks", value: repo.forksCount, icon: "tuningfork", color: .blue)
            StatCard(title: "Issues", value: repo.openIssuesCount, icon: "exclamationmark.circle", color: .red)
        }
        // Force the HStack to measure its ideal height based on the tallest card
        .fixedSize(horizontal: false, vertical: true)
    }
}
