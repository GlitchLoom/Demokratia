# E3 — Feed

Goal: a chronological list of upcoming events for the followed city, with explicit user filters and no ranking.
BE readiness: ⚠️ — `GET /api/events/` exists: public, published events only, ordered by `start_at`, **plain array without pagination**, filters only `lat`+`lon`+`radius_km` (all three together, else `400` with a bare list of messages). No date/category/organizer filter, no search, no cursor.
Agents: Domain, Data, Presentation, UI, Testing.

**Event JSON (current)**: `id, title, description, category, start_at, end_at, address, latitude, longitude, status, created_by, created_at`.

**Proposed contract additions (not available yet)**: cursor pagination (`?cursor=`, response `{results, next}`), `date_from`, `date_to`, `category` (multi), `organization`, `include_past=true` for history.

**Guardrail**: the client never reorders or hides results. Filters that the BE cannot apply are *disabled in the UI* (or applied locally only if explicitly labeled), not silently simulated.

### E3-T1 — Domain: `Event` and `EventRepository`
- **What**: Entity `Event` (id, title, description, category, startAt, endAt?, address, location, status, createdBy, createdAt), `EventStatus` enum (`pubblicato, sospeso, rimosso, cancellato`), `EventRepository.list(filter)`, `GetFeedUseCase`.
- **Tech**: `EventFilter` (center+radius, categories, dateRange) — fields not supported by the BE are carried but flagged. Parse `start_at` as UTC → local time zone in presentation (BE uses Europe/Rome, `USE_TZ`).
- **Test**: Entity/use-case tests; status parsing with unknown value → safe default; date handling around DST.
- **Depends on**: E0-T2
- **Human review**: Filter model vs BOOTSTRAP §6 (date range, category, organizer, distance).

### E3-T2 — Data: events list API integration
- **What**: `EventRepositoryImpl.list` calling `GET /api/events/` with `lat`/`lon`/`radius_km`, DTO + mapper.
- **Tech**: Handle the "all three or none" rule in the filter → query mapper (never send a partial set). `latitude`/`longitude` in responses. Accept both a bare array and the future `{results,next}` shape behind one mapper. Errors via E0-T7.
- **Test**: Mapper tests with real sample payloads; query-building tests (none / all three / partial → error before sending); contract test against the local BE with a seeded event.
- **Depends on**: E3-T1, E0-T7
- **Human review**: Seed event used in the contract test; that unbounded lists are acceptable for the pilot.

### E3-T3 — Screen: Feed (read-only list)
- **What**: "Prossimi eventi" with city label and `EventCard` list, loading/empty/error states, pull-to-refresh.
- **Tech**: ViewModel exposes `FeedState` (loading, data, empty, error). Past events (start before now) are not shown in the feed (history is a separate action). Mockup: `Feed` screen.
- **Test**: ViewModel tests for each state; widget test list rendering order == repository order; golden light/dark; error → retry.
- **Depends on**: E3-T2, E0-T6, E0-T8
- **Human review**: Order is exactly the BE order; empty-state copy tells the user what to do.

### E3-T4 — Distance filter ("Vicino a me")
- **What**: Chip that filters by radius around the device position or the selected city.
- **Tech**: Needs `LocationService` (E2-T3). Uses BE `lat/lon/radius_km`. Radius choice (e.g. 2/5/10/25 km) in a small sheet. If permission denied, the chip explains and falls back to city center.
- **Test**: ViewModel tests (granted/denied, radius change re-queries); query contains all three params.
- **Depends on**: E3-T3, E2-T3
- **Human review**: Permission wording; no location sent unless the user taps the chip.

### E3-T5 — [BE-blocked] Date and category filters
- **What**: "Questa settimana" and category chips driven by the BE.
- **Tech**: Until the BE ships `date_from/date_to/category`, keep the chips **hidden or disabled** with a note in the PR. When shipped: extend `EventFilter` mapping, add chips from onboarding preferences as the *initial* selection (user can clear).
- **Test**: Query-building tests; ViewModel tests that clearing all filters restores the full feed; preferences never apply silently after the user cleared them.
- **Depends on**: BE filters; E3-T3, E2-T4
- **Human review**: Confirm the BE's semantics (inclusive bounds, time zone) before enabling.

### E3-T6 — [BE-blocked] Pagination (infinite scroll)
- **What**: Load more as the user scrolls.
- **Tech**: Cursor from the BE; the list is append-only and stable even when new events are created meanwhile. Until then: cap what the client renders only if the BE response is huge (document the limit) — do not paginate locally by reordering.
- **Test**: ViewModel tests (append, last page, error on page 2 keeps page 1, refresh resets cursor).
- **Depends on**: BE pagination; E3-T3
- **Human review**: Scroll performance on a mid-range Android device.

### E3-T7 — Past events history
- **What**: A "Eventi passati" view.
- **Tech**: Needs BE support for past events (today only future/published are guaranteed — verify) via `include_past`/`date_to`.
- **Test**: Same list tests with a past-only filter.
- **Depends on**: BE history; E3-T3
- **Human review**: Placement in the UI (not in the main feed).
