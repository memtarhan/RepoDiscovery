//
//  WebView.swift
//  RepoDiscovery
//
//  Created by Mehmet Tarhan on 6.07.2026.
//  Copyright © 2026 MEMTARHAN. All rights reserved.
//

import SafariServices
import SwiftUI

/// A SwiftUI wrapper for SFSafariViewController to handle in-app web browsing.
struct WebView: UIViewControllerRepresentable {
    let url: URL

    // Closure to handle the delegate callback
    let onFinished: () -> Void

    // 1. Create the Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(onFinished: onFinished)
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false

        let safariVC = SFSafariViewController(url: url, configuration: configuration)
        safariVC.preferredControlTintColor = .systemBlue

        // 2. Assign the coordinator as the delegate to listen for interactions
        safariVC.delegate = context.coordinator

        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let onFinished: () -> Void

        init(onFinished: @escaping () -> Void) {
            self.onFinished = onFinished
        }

        // 3. This UIKit delegate method fires exactly when the "Done" button is tapped
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            onFinished()
        }
    }
}
