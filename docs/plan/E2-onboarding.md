# E2 — Onboarding (city + categories)

Goal: after sign-in, the citizen chooses city(ies) and initial categories; both only pre-filter the feed (never profiling).
BE readiness: ❌ — there is no City/Area entity and no stored preferences. Today the only geographic tool is `lat`/`lon`/`radius_km` on `GET /api/events/`.
Agents: Domain, Data, Presentation, UI, Coordinator, Testing.

**Proposed contract (to agree with the BE; not available yet)**
- `GET /api/cities/` → `[{id, name, center:{latitude,longitude}, default_radius_km}]`
- `GET/PUT /api/me/preferences/` → `{city_ids:[…], categories:[…]}`

**Fallback until the BE ships**: preferences stored **locally only**; the city list is a small bundled seed (pilot city: Bologna) with a center point, and the feed uses the radius filter around it.

### E2-T1 — Domain: `City`, `Preferences`, use cases
- **What**: Entities `City` (id, name, center, defaultRadiusKm), `Preferences` (cityIds, categories), `EventCategory` enum matching BE values: `manifestazione, corteo, assemblea, dibattito, raccolta_firme, culturale, sciopero, altro`. Use cases `GetCitiesUseCase`, `GetPreferencesUseCase`, `SavePreferencesUseCase`.
- **Tech**: Pure Dart. Categories are a **client pre-filter only** (BOOTSTRAP §6) — document it in the use case.
- **Test**: Use-case tests with a fake repository; enum parsing of every BE category string (unknown value → `altro`, no crash).
- **Depends on**: E0-T2
- **Human review**: Category list and labels (Italian) vs the mockup chips.

### E2-T2 — Data: local preferences + seed cities
- **What**: `PreferencesRepository` and `CitiesRepository` implemented locally (secure/local storage + bundled JSON seed).
- **Tech**: Behind the interfaces of E2-T1 so the BE version swaps in later. No personal data beyond the choices.
- **Test**: Repository tests (save/load/overwrite, empty state, corrupt storage → defaults).
- **Depends on**: E2-T1
- **Human review**: Pilot city center coordinates and default radius.

### E2-T3 — Screen: Onboarding step 1 — choose city
- **What**: "Quale città vuoi seguire?" with a searchable list; Continue disabled until ≥1 city.
- **Tech**: Mockup: `Onboarding` screen, step "passo 1 di 2". Optional location permission to *suggest* a city — never blocks if denied (BOOTSTRAP §9.1). Permission handling isolated behind a `LocationService` interface.
- **Test**: ViewModel tests (selection, empty state, permission granted/denied/permanently denied); widget test for the disabled button; golden light/dark.
- **Depends on**: E2-T2, E0-T5
- **Human review**: Permission rationale copy; the app works fully when location is denied.

### E2-T4 — Screen: Onboarding step 2 — choose categories
- **What**: Chips for the 8 categories, ≥0 selectable, "Salta per ora".
- **Tech**: Chips from `CategoryChip`; Copy states these only pre-filter the feed. Writes preferences on finish.
- **Test**: ViewModel tests (toggle, skip, finish persists); semantics test (selected state read aloud).
- **Depends on**: E2-T3
- **Human review**: Skipping must produce an unfiltered feed.

### E2-T5 — Wire onboarding into the app flow
- **What**: After sign-in, show onboarding only if no preferences exist; manage cities later from Profile (E8).
- **Tech**: Coordinator decision based on `GetPreferencesUseCase`; relaunch mid-onboarding resumes at the right step.
- **Test**: Coordinator tests for the three states (no prefs / prefs / partial); integration test full first-run.
- **Depends on**: E2-T4, E1-T8
- **Human review**: First-run walkthrough on a real device.

### E2-T6 — [BE-blocked] Switch to BE cities and preferences
- **What**: Replace local sources with `/api/cities/` and `/api/me/preferences/` once published.
- **Tech**: New data sources; keep the local one as cache. Run the shared repository test suite against both.
- **Test**: Same repository suite on fake and real; contract test against a running BE; migration of locally saved preferences to the BE on first sync.
- **Depends on**: BE cities + preferences; E2-T5
- **Human review**: What is sent to the BE (only the choices, nothing else).
