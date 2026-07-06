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
    let size: CGFloat

    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable()
                .scaledToFill()

        } placeholder: {
            Color.gray.opacity(0.3)
                .overlay(ProgressView())
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
