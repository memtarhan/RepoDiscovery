# RepoDiscovery

An iOS application engineered to browse and discover GitHub repositories. Built from the ground up to demonstrate iOS development practices, this project showcases strict adherence to Clean Architecture, modern Swift 6 Concurrency, and a highly scalable UI Design System.


## 🏛 Architecture & Design Patterns

The application enforces a strict separation of concerns utilizing **Clean MVVM**, decoupling the business logic from the presentation layer and ensuring absolute testability.

* **Domain-Driven Design:** The app utilizes strict Data Transfer Objects (`RepositorySearchDTO`) at the network boundary, mapping them cleanly to pure, immutable Domain Models (`RepositoryModel`) before they reach the UI.
* **Composition Root (DI Container):** Views and ViewModels do not instantiate their own dependencies. The `AppDIContainer` acts as the single source of truth, wiring up the `NetworkClient`, `SearchRepository`, and injecting them at the root of the application lifecycle.
* **Centralized Routing:** Navigation is decoupled from the SwiftUI view hierarchy using an `@Observable` `SearchRouter`. This enables programmatic deep-linking, prevents "Prop Drilling," and cleanly bridges UIKit delegate events (like `SFSafariViewController` closures) back into the SwiftUI state flow.

## 🚀 Key Technical Highlights

### 1. Framework-Grade Network Layer

The custom `NetworkClient` abstracts `URLSession` into a highly resilient, generic data pipeline:

* **Request Coalescing:** Utilizes a custom `RequestTaskCoordinator` actor. If multiple identical requests fire simultaneously (e.g., rapid button tapping), the actor traps the duplicates and attaches them to the single in-flight `Task`, drastically reducing API load.
* **Intelligent Retry & Backoff:** Implements exponential backoff with jitter to gracefully recover from transient `5xx` server errors or network timeouts without triggering "thundering herd" scenarios on the backend.
* **Smart Debouncing:** Search input is throttled natively using `Task.sleep(for: .seconds(0.5))` and task cancellation, preventing the exhaustion of GitHub’s unauthenticated API rate limits.

### 2. Swift 6 Strict Concurrency

The codebase is engineered to be **100% free of Swift 6 data-race warnings**.

* **Actor Isolation:** `SearchViewModel` and `SearchRouter` are explicitly bound to the `@MainActor` to guarantee thread-safe UI rendering.
* **Immutable Traversal:** All domain models and DTOs conform to the `Sendable` protocol, mathematically proving to the compiler that cross-thread data passing is race-condition free.

### 3. High-Performance Image Caching

Images are not fetched blindly. `ImageCacheManager` is a custom, two-tier `actor` that completely replaces `NSCache` limitations:

* **Tier 1 (Memory):** Fast-access, count-limited RAM storage.
* **Tier 2 (Disk):** Atomic file writing to the device's cache directory using `SHA256` hashing for collision-proof filenames.
* **In-Flight Tracking:** If a cell is recycled while an image is downloading, the actor tracks the active `Task` and prevents duplicate network calls for the same avatar.

### 4. Semantic UI & Design System

Hardcoded colors and math are banished. The application relies on `AppTheme`, a centralized token system:

* **Semantic Typography:** Modifiers like `.textStyle(.header)` map to underlying dynamic system fonts, ensuring perfect **Dynamic Type (Accessibility)** support and allowing instant, global re-branding.
* **Adaptive Materials:** The custom Shimmering Skeleton loaders utilize `UIColor.tertiarySystemFill`, natively adapting to Light Mode, Dark Mode, and High Contrast environments without manual intervention.

## 🛠 Diagnostics & Testing

* **Actor-Backed Mocking:** Asynchronous ViewModels are tested using an actor-isolated `MockSearchRepository`, guaranteeing thread-safe state mutations during XCTest assertions.
* **Black-Box Network Testing:** The coalescing and retry logic is validated using a custom `URLProtocol` mock, testing concurrent `TaskGroup` behavior without hitting the live internet.

## ⚙️ Requirements & Installation

* **Xcode 15.0+**
* **iOS 17.0+** (Leverages `@Observable`, `ContentUnavailableView`, and modern `Task.sleep` APIs)
* **Swift 5.10+** (Strict Concurrency Checking enabled)

**To Run:**

1. Clone the repository.
2. Open `RepoDiscovery.xcodeproj`.
3. Build and run on the iOS Simulator or a physical device.

*Note: GitHub limits unauthenticated API requests to 10 per minute. If you rapidly spam the search functionality beyond this limit, the application will gracefully display a 429 Rate Limit error via the native `ContentUnavailableView`.*



***Created by:*** 
# Mehmet Tarhan
