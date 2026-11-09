# ADR 0005 — Dependency injection / app composition

- **Status**: **Accepted** (by the project owner, 2026-11-07)
- **Task**: E0-T1 · **Date**: 2026-11-07

## Context
Single composition point in `lib/di`: nobody else instantiates concrete `lib/data` classes. It wires domain use cases, data implementations (real or `Fake…Repository` for BE-blocked work), ViewModels and the root Coordinator, and selects per-flavor config (E0-T3). Tests must be able to swap any dependency for a fake.

## Options considered
| Option | Pros | Cons | Testability | MVVM-C fit |
|---|---|---|---|---|
| **A. Manual constructor injection + one `AppContainer` in `lib/di`** | Zero deps; dependencies explicit in constructors; compile-time errors for missing wiring | Container code grows by hand; lazy singletons written manually (`late final`) | Excellent: tests build objects directly or build a container with fakes | Excellent: Coordinator receives factories for ViewModels |
| B. `get_it` (service locator) | Popular, lazy singletons, scopes, easy reset in tests | Global access invites `GetIt.I<...>()` calls from anywhere, hiding dependencies and breaking the single-composition rule | Good (`reset`, re-register fakes) | Good if restricted to `lib/di` by lint |
| C. `get_it` + `injectable` | Annotations generate registration | Codegen; annotations spread into domain/data classes | Good | Fair |
| D. Riverpod/Provider as DI | Tree-scoped overrides | Couples DI to widget tree; conflicts with ADR 0001 | Good | Fair |

## Recommendation
**A** — an `AppContainer` (plain Dart) built in `main()` from the flavor config, exposing lazily created singletons (`ApiClient`, repositories, use cases) and ViewModel factories handed to the Coordinator. A `TestContainer`/overrides constructor lets tests and the "fake backend" mode replace repositories. Constructor injection everywhere else; no global locator.

## Rejected alternatives
- **B**: acceptable fallback if the graph becomes unwieldy; then only `lib/di` may reference `GetIt` (enforce via lint/import rule).
- **C**: codegen and annotations leaking into layers.
- **D**: mixes DI with UI tree, conflicts with ADR 0001.

## Consequences
Container file is reviewed whenever a dependency is added (the DI agent's job).
