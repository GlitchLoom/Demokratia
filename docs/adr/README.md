# Architecture Decision Records

Short records of the core technical choices (task E0-T1). An ADR is **Proposed** until a human accepts it; only a human changes the status to Accepted/Rejected. Later tasks read accepted ADRs.

| ADR | Topic | Status | Recommendation (one line) |
|---|---|---|---|
| [0001](0001-state-management.md) | State management | Accepted | Flutter SDK `ChangeNotifier`/`ValueNotifier` ViewModels + `ListenableBuilder`; intents as a stream to the Coordinator; no state package. |
| [0002](0002-router.md) | Router | Accepted | `go_router`, wrapped by Coordinator classes; `StatefulShellRoute` for the tabs; no codegen. |
| [0003](0003-http-client.md) | HTTP client | Accepted | `dio` (no retrofit) behind an `ApiClient` interface in `lib/data`; `QueuedInterceptor` for JWT refresh. |
| [0004](0004-local-db-cache.md) | Local DB / cache | Accepted | `drift`, adopted only when E5/E9-T1 need it; in-memory cache until then. |
| [0005](0005-dependency-injection.md) | DI | Accepted | Manual constructor injection with one `AppContainer` in `lib/di`; `get_it` only as fallback, confined to `lib/di`. |
| [0006](0006-minimum-platform-versions.md) | Min OS versions | Accepted (re-verify in E0-T2) | iOS 15.0, Android minSdk 24; targetSdk per Google Play requirement at release. |
| [0007](0007-nostr-and-secure-storage-libs.md) | Nostr crypto + secure storage | Proposed (list only) | No decision: candidate packages for E1-T2's security gate. |

Template: Status, Context, Options considered (pros/cons, testability, MVVM-C fit), Recommendation, Rejected alternatives, Consequences. Keep each under ~40 lines.
