//
//  AvatarView.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SwiftUI

struct AvatarView: View {
    let url: URL?
    var size: AppTheme.AvatarSize = .medium

    var body: some View {
        CachedAsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: size.rawValue, height: size.rawValue)
                .clipShape(Circle())
        } placeholder: {
            Circle()
                .fill(AppTheme.Colors.surface)
                .frame(width: size.rawValue, height: size.rawValue)
        }
        .overlay(
            Circle().stroke(AppTheme.Colors.borderStandard, lineWidth: 1)
        )
    }
}
