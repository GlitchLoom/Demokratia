# ADR 0001 — State management for ViewModels

- **Status**: **Accepted** (by the project owner, 2026-11-07)
- **Task**: E0-T1 · **Date**: 2026-11-07

## Context
MVVM-C (`.claude/skills/mvvm-c-pattern`): one ViewModel per mockup screen, widgets only listen to state, ViewModels emit one-shot intents and never navigate; the Coordinator decides. Constraints: few dependencies, high testability with plain `flutter test`, `lib/domain` free of Flutter imports.

## Options considered
| Option | Pros | Cons | Testability | MVVM-C fit |
|---|---|---|---|---|
| **A. `ChangeNotifier`/`ValueNotifier` + `ListenableBuilder` (Flutter SDK only)** | Zero deps; matches Flutter's official app-architecture guide (MVVM); easy to read | Manual `notifyListeners`; no built-in async/"command" helper (small helper needed) | Very good: instantiate VM with fake use cases, assert state | Native: VM = `ChangeNotifier`, intents via a `Stream`/callback the Coordinator subscribes to |
| B. `provider` + ChangeNotifier | Same model as A plus widget-tree lookup | Extra dep; tempts widgets to look up services (service location in UI) | Good | Good, but overlaps with DI (ADR 0005) |
| C. Riverpod | Powerful, compile-safe providers, async helpers | Brings its own DI and lifecycle model; codegen common; providers tend to replace ViewModels/Coordinator split | Good (overrides) | Partial: architecture drifts toward "providers everywhere" |
| D. Bloc/Cubit | Explicit events/states, strong conventions, `bloc_test` | Boilerplate; two deps; a Cubit is effectively a ViewModel with extra ceremony | Very good | Good (events ≈ intents) but heavier than needed |

## Recommendation
**A** — ViewModels extend `ChangeNotifier` and expose an immutable state object; widgets use `ListenableBuilder`/`ValueListenableBuilder`. One-shot navigation intents are exposed as a `Stream<Intent>` (or a typed callback) consumed by the Coordinator. Add a tiny in-house `Command` helper for async actions (running/error/result), as in the Flutter architecture guide. ViewModels are passed in by the Coordinator/composition root (ADR 0005), not looked up from the widget tree.

## Rejected alternatives
- **B (provider)**: only adds tree lookup, which we do not want in widgets.
- **C (Riverpod)**: overlaps with DI and router concerns; blurs the ViewModel/Coordinator split.
- **D (Bloc)**: valid, but more ceremony and dependencies for the same result.

## Consequences
Team must keep state immutable by convention (consider `equatable` or records). Revisit if screens need complex derived/async state.
