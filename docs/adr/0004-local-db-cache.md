# ADR 0004 — Local database / offline cache

- **Status**: **Accepted** (by the project owner, 2026-11-07)
- **Task**: E0-T1 · **Date**: 2026-11-07

## Context
Needs are narrow (`.claude/skills/offline-first-caching`): last known feed, saved/subscribed events available offline (E5), possibly event drafts; cache-first then refresh; cleared on sign-out and account deletion (E8, E9-T1). Data minimization (BOOTSTRAP §4.4). Tokens and the Nostr key do **not** go here (secure storage, ADR 0007). No feature needs persistence before E5/E9.

## Options considered
| Option | Pros | Cons | Testability |
|---|---|---|---|
| **A. `drift` (SQLite)** | Typed queries (by date, by id), migrations, reactive streams, actively maintained; in-memory DB for tests | Codegen (`build_runner`); bundles `sqlite3` native libs (~1 MB) | Very good: `NativeDatabase.memory()` in unit tests |
| B. `hive` / `hive_ce` | Simple key-value boxes, fast, no native deps | Original `hive` effectively unmaintained (community fork `hive_ce`); weak querying; manual migrations | Good |
| C. `sqflite` | Plain SQLite, mature | Raw SQL and mapping by hand; no reactive queries; needs FFI variant for host tests | Fair |
| D. JSON files / `shared_preferences` | Zero/near-zero deps, trivially wipeable | No queries, whole-blob rewrites; prefs not meant for data | Good for tiny scope only |
| E. `isar` | Fast, queries | Original author stepped back; maintenance uncertain | Fair |

All options are confined to `lib/data` behind repository interfaces, so MVVM-C fit is equal; the choice only affects the data layer.

## Recommendation
**A (`drift`)**, **added only when the first task needs it** (E5 saved events or E9-T1), not in E0-T2. Until then repositories keep an in-memory cache. One small schema (events + cache metadata with last-sync timestamp), a single `clearAll()` used by sign-out/account deletion.

## Rejected alternatives
- **B**: maintenance risk and poor querying for date-ordered saved events.
- **C**: more hand-written mapping for no gain over drift.
- **D**: acceptable fallback if the human prefers zero native deps and the scope stays tiny.
- **E**: maintenance uncertainty.

## Consequences
Introduces `build_runner` into the toolchain when adopted; on-device DB is not encrypted (store only public event data; privacy review in E9-T1).
