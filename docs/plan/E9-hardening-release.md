# E9 — Hardening and release

Goal: the app is resilient offline, accessible, observable only to the extent we choose, and shippable.
BE readiness: n/a. Do these in parallel with feature epics when possible; the tasks are independent.
Agents: Data, UI, DI & Composition, Testing.

### E9-T1 — Offline cache for feed and saved events
- **What**: Show the last known feed and the saved events without network, with a "dati non aggiornati" indicator and last-sync time.
- **Tech**: Local DB per ADR; scope-limited cache (current feed, saved events) — see `.claude/skills/offline-first-caching/SKILL.md`. Cached data cleared on sign-out and account deletion. Cache-first display, then refresh.
- **Test**: Repository tests (cache hit, stale, refresh failure keeps cache, cleared on sign-out); airplane-mode manual run.
- **Depends on**: E3-T2, E5-T2
- **Human review**: What exactly is cached (privacy).

### E9-T2 — Connectivity and error UX pass
- **What**: Consistent loading/empty/error/retry states across screens; offline banner; friendly messages mapped from `Failure` types.
- **Tech**: One shared `StateView` widget; Italian copy table; never show raw BE messages for 5xx.
- **Test**: Widget tests for each state; golden of the shared widget.
- **Depends on**: E0-T7
- **Human review**: Copy review.

### E9-T3 — Accessibility audit
- **What**: Verify every screen with TalkBack and VoiceOver, 2× text scale, high contrast, reduced motion.
- **Tech**: Checklist from `accessibility-fundamentals`; fix findings as separate small tasks.
- **Test**: Semantics tests for key widgets; manual audit notes in the PR.
- **Depends on**: E3-T3, E4-T5, E7-T5 (screens exist)
- **Human review**: You (or an assistive-tech user) run it.

### E9-T4 — Privacy review of data flows
- **What**: Document every piece of data stored on-device or sent to the BE/Firebase; confirm no ads/analytics SDKs, no tracking identifiers.
- **Tech**: Output `docs/privacy-data-flows.md`; verify with a network capture on a test device.
- **Test**: Dependency list check (no analytics/ad packages); capture shows only expected hosts.
- **Depends on**: E1–E7 substantially done
- **Human review**: **Privacy gate.**

### E9-T5 — Security hardening
- **What**: Release builds use HTTPS only; certificate/cleartext rules; obfuscation; no debug logging; secure storage settings (e.g. iOS keychain accessibility); jailbreak/root checks are out of scope unless decided.
- **Tech**: Android network security config; iOS ATS; confirm key never in backups (Android `allowBackup`/data extraction rules, iOS keychain not synced unless chosen).
- **Test**: Release build smoke test; static check that cleartext is rejected in release.
- **Depends on**: E1-T7
- **Human review**: **Security gate.**

### E9-T6 — Integration test suite for the golden paths
- **What**: Automated flows with a fake backend: first run → identity → onboarding → feed → detail → join; create event; follow organization.
- **Tech**: `integration_test` with fake repositories wired in `di/`; same flows re-run against a real local BE in a dev-only job.
- **Test**: This is the test; flaky tests are fixed, not retried blindly.
- **Depends on**: E1–E6 as available
- **Human review**: Flow coverage list.

### E9-T7 — CI/CD and store readiness
- **What**: Build pipelines for signed Android AAB and iOS IPA, versioning, release notes, TestFlight / Play internal testing.
- **Tech**: Signing credentials are **yours**: stored as CI secrets by a human; agents never see them. Bundle ids, icons, splash, store listings (Italian), privacy labels.
- **Test**: A tagged build produces installable artifacts on both stores' internal tracks.
- **Depends on**: E0-T9, E9-T4
- **Human review**: **You operate the store accounts and secrets.**

### E9-T8 — Backend production readiness checklist (dependency report)
- **What**: Produce a list for the BE team of what the client needs before launch (pagination, token lifetime, throttling for event creation, gunicorn/HTTPS, challenge cleanup, API versioning prefix, CASCADE on `created_by`, committed Nostr code).
- **Tech**: Doc only; link each item to the client task it blocks.
- **Test**: n/a.
- **Depends on**: any
- **Human review**: You triage with the BE owner.
