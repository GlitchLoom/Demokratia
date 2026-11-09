# ADR 0002 — Router and navigation backbone

- **Status**: **Accepted** (by the project owner, 2026-11-07)
- **Task**: E0-T1 · **Date**: 2026-11-07

## Context
The Coordinator owns all navigation: three tabs (Feed, Notifiche, Profilo) with preserved state, a central FAB opening "Crea evento", push routes (event detail, organization), onboarding gate, and deep links / push taps later (E7-T6). Widgets and ViewModels never call `Navigator` or `context.go`.

## Options considered
| Option | Pros | Cons | Testability | MVVM-C fit |
|---|---|---|---|---|
| **A. `go_router`** | Maintained by the Flutter team; URL-based (deep links come almost free); `StatefulShellRoute` keeps per-tab stacks; `redirect` for auth/onboarding gate | API churn across majors; string paths need typed wrappers to avoid typos | Good: `GoRouter` injectable, widget tests with a real router; Coordinator interface fakeable | Good if wrapped: only the Coordinator holds the `GoRouter` |
| B. Raw Navigator 2.0 (`RouterDelegate`) | No dependency; full control | Lots of boilerplate; deep-link parsing hand-written | Good but more code to test | Very good (Coordinator = delegate), at high cost |
| C. `auto_route` | Typed routes, nested tabs | Codegen (`build_runner`); third-party maintenance | Good | Good |
| D. `beamer` | Coordinator-like "beam locations" | Smaller community, slower maintenance | Fair | Good |

## Recommendation
**A (`go_router`)**, hidden behind Coordinator classes in `lib/coordinator`: e.g. `AppCoordinator` exposes `showEvent(id)`, `openCreateEvent()`, `selectTab(...)`; route paths and `GoRouter` stay private to that layer. Tabs via `StatefulShellRoute.indexedStack`. Auth/onboarding gate via `redirect` fed by a session `Listenable`. Typed path helpers (hand-written, no codegen) to avoid stringly-typed calls.

## Rejected alternatives
- **B**: too much bespoke code for deep links and tab state.
- **C**: adds codegen just for routes.
- **D**: maintenance risk.

## Consequences
Pin the `go_router` major version; upgrades reviewed. Deep-link scheme/domain left to E7.
