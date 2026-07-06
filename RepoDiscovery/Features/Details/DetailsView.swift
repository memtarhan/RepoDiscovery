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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                statsSection
                if let description = repo.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.title2.bold())

                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if let url = repo.htmlUrl {
                Link(destination: url) {
                    Label("Open in Safari", systemImage: "safari")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(spacing: 16) {
            AvatarView(url: repo.owner.avatarUrl, size: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text(repo.name)
                    .font(.title.bold())

                Text(repo.owner.login)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(title: "Stars", value: repo.stargazersCount, icon: "star.fill", color: .yellow)
            StatCard(title: "Forks", value: repo.forksCount, icon: "arrow.y.branch", color: .blue)
            StatCard(title: "Issues", value: repo.openIssuesCount, icon: "exclamationmark.circle", color: .red)
        }
    }
}
