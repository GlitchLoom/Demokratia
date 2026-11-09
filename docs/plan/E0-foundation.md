# E0 — Foundation

Goal: a Flutter project that builds, with the Clean Architecture + MVVM-C skeleton, the design system from the mockup, and a tested HTTP layer ready for any feature epic.
BE readiness: ✅ (only `/api/schema/` and the existing endpoints are needed).
Agents: DI & Composition, UI & Design System, Data, Testing.

### E0-T1 — Decide and record the core technical choices (ADRs)
- **What**: Choose and document state management, router, HTTP client, local DB, DI approach, and minimum iOS/Android versions. One short ADR per choice in `docs/adr/`.
- **Tech**: Candidates — state: `ChangeNotifier`/Provider vs Riverpod vs Bloc; router: `go_router`; HTTP: `dio`; DB: `drift` vs `hive`; DI: `get_it` or manual. Criteria: testability, fit with MVVM-C, team familiarity, maintenance. Keep dependencies few (no analytics/ad SDKs).
- **Test**: n/a (documents). Check that each ADR states the alternatives rejected.
- **Depends on**: —
- **Human review**: **You decide.** The agent proposes, a human picks. Later tasks read these ADRs.

### E0-T2 — Create the Flutter project and folder skeleton
- **What**: Run `flutter create` **in the repository root** (keeping `docs/`, `.claude/`, `AGENTS.md`, `CLAUDE.md`) so the repo itself is the Flutter project; the layer folders already exist under `lib/`: `domain/`, `data/`, `presentation/`, `coordinator/`, `di/`, `designsystem/`. Merge the generated `.gitignore` with the existing one.
- **Tech**: `flutter create` with org id agreed with you; add lint rules (`flutter_lints` + a rule/`import_lint` forbidding `domain` → `flutter`/`data` imports). Flavors `dev`/`prod` placeholders.
- **Test**: App launches on both platforms (blank page); `flutter analyze` and the import-boundary lint pass; a deliberate violation fails the lint (prove it once, then remove).
- **Depends on**: E0-T1
- **Human review**: Folder layout matches the agents' README files; org/bundle id correct.

### E0-T3 — Environment configuration
- **What**: Configurable API base URL per flavor (dev → local BE, prod → placeholder).
- **Tech**: `--dart-define` or flavor config read in `di/`. Local BE is `http://localhost:8000` (Android emulator needs `10.0.2.2`; iOS simulator `localhost`; real device = LAN IP). Cleartext HTTP allowed **only** in debug/dev.
- **Test**: Unit test that the config resolves per flavor; manual check from emulator, simulator.
- **Depends on**: E0-T2
- **Human review**: No prod URL or secret committed; cleartext is dev-only.

### E0-T4 — Design tokens and theme from the mockup
- **What**: Light/dark `ThemeData` + `ThemeExtension` with the Timbro Comunale palette, type scale (serif titles, sans UI, mono metadata) and spacing.
- **Tech**: Source: `docs/mockup/design-system.html` + the `:root` blocks in `docs/mockup/index.html` (light + dark values). Serif/sans/mono: use system fonts equivalents or bundle licensed fonts (decide). Category → color mapping per `.claude/skills/design-token-translation/SKILL.md`.
- **Test**: Golden test of a token sheet (light+dark); unit test that every token exists in both themes.
- **Depends on**: E0-T2
- **Human review**: Compare the golden image against the mockup side by side.

### E0-T5 — Core components: buttons, chips, tags
- **What**: `PrimaryButton`, `GhostButton`, `JoinedButton`, `DangerButton`, `CategoryChip`, `CategoryTag`.
- **Tech**: Stateless widgets, tokens only (no hardcoded colors), semantic labels, text scaling safe. Skill: `flutter-widget-patterns`, `accessibility-fundamentals`.
- **Test**: Widget tests (tap, disabled, selected state exposed in `Semantics`), goldens light/dark at 1.0× and 2.0× text scale.
- **Depends on**: E0-T4
- **Human review**: Visual match with `design-system.html` (§3–§4).

### E0-T6 — Core components: event card, notification row, org header, profile row
- **What**: `EventCard`, `NotifRow`, `OrgHeader`, `ProfileRow`, plus `BottomNav` with central FAB.
- **Tech**: Pure presentational widgets taking plain view-model data (no domain/data imports). Sample data from the mockup ("Corteo per il clima", "Comitato Bologna Clima").
- **Test**: Goldens light/dark; semantics test for the card (title, date, place read in order); long-title overflow test.
- **Depends on**: E0-T5
- **Human review**: Match `index.html` screens; check long titles and 2× text scale.

### E0-T7 — HTTP client with error mapping
- **What**: Injectable `ApiClient` (interface in `data`, implementation on `dio`) with base URL, JSON, timeouts, and mapping of BE errors to a domain `Failure` type.
- **Tech**: Map the BE formats: `{"detail": "..."}`, `{"field": ["msg"]}`, bare list of strings (geo filter), `{"event": ...}` (Nostr), network/timeout. Messages from the BE are Italian — pass through for display, never parse them for logic; branch on status codes. No logging of `Authorization`.
- **Test**: Unit tests with a fake adapter for each error shape + 401, 429, 5xx, timeout, malformed JSON.
- **Depends on**: E0-T2, E0-T3
- **Human review**: Failure taxonomy (what the UI can distinguish).

### E0-T8 — Navigation shell with placeholder screens
- **What**: Root Coordinator with the three tabs (Feed, Notifiche, Profilo), FAB opening a placeholder "Crea evento" sheet, push route placeholders for event detail and organization.
- **Tech**: Router per ADR; Coordinator owns navigation, ViewModels emit intents only (skill `mvvm-c-pattern`). Deep-link scheme left for E7.
- **Test**: Widget/integration test: tab switching preserves state, back stack works, FAB opens and closes the sheet.
- **Depends on**: E0-T1, E0-T6
- **Human review**: Matches the mockup flow; no `Navigator`/`context.go` calls inside widgets.

### E0-T9 — Test harness and CI
- **What**: Shared test helpers (fake repositories base, pump helpers), and a CI workflow running `flutter analyze` + `flutter test`.
- **Tech**: GitHub Actions on PR. Coverage reported, no gate yet.
- **Test**: CI green on a PR with a failing test turning it red (prove once).
- **Depends on**: E0-T2
- **Human review**: Workflow permissions minimal; no secrets needed.

### E0-T10 — Contract smoke test against the BE OpenAPI
- **What**: A script/test that fetches `/api/schema/` from a running local BE and checks the endpoints and fields the client hardcodes still exist.
- **Tech**: Dev-only, not part of CI by default (needs Docker BE). Compare a small committed list of `(method, path, required fields)`.
- **Test**: Passes against current BE; fails if a field is renamed (try it once).
- **Depends on**: E0-T7
- **Human review**: The list of endpoints it protects.
