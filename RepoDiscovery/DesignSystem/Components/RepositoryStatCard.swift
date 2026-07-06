//
//  RepositoryStatCard.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        GroupBox {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(AppTheme.Typography.subheader)
                    .foregroundColor(color)

                Text("\(value)")
                    .textStyle(.subheader)

                Text(title)
                    .textStyle(.metadata)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
