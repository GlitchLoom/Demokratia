# E4 — Event detail, create, edit

Goal: open an event, share it, and let a signed-in citizen publish (and later edit/cancel) events.
BE readiness: ⚠️ — `POST /api/events/` works (auth required): body `title` (≤200), `description`, `category`, `start_at`, `end_at?`, `address` (≤300), `lat`, `lon`. `status` is read-only; no GET by id, no PATCH/DELETE, no image, no external links, no organization, no rate limit on creation (the client must still handle `429`).
Agents: Domain, Data, Presentation, UI, Coordinator, Testing.

**Proposed contract additions**: `GET /api/events/{id}/`, `PATCH /api/events/{id}/` (creator/org admin), `POST /api/events/{id}/cancel/`, fields `cover_image`, `links[]`, `organization`; geocoding is **server-side** (BOOTSTRAP / wireframe): today the client must send lat/lon, so E4-T4 includes a stopgap.

### E4-T1 — Domain: create/get use cases
- **What**: `CreateEventUseCase`, `GetEventUseCase`, validation rules (title required, start in the future, end ≥ start, address required).
- **Tech**: Validation lives in the domain (client UX only; BE revalidates — BOOTSTRAP §9.1). `NewEvent` input entity separate from `Event`.
- **Test**: Validation table tests (every rule, boundaries around "now").
- **Depends on**: E3-T1
- **Human review**: Rules and error messages.

### E4-T2 — Data: create event integration
- **What**: `EventRepositoryImpl.create` → `POST /api/events/`.
- **Tech**: Request DTO uses `lat`/`lon`; response uses `latitude`/`longitude` — separate DTOs. Map `400` field errors to per-field failures; `401` triggers the refresh interceptor; `429` → `rateLimited`.
- **Test**: DTO/mapper tests; failure mapping for each field error; contract test creating then listing the event on the local BE.
- **Depends on**: E4-T1, E1-T5
- **Human review**: Sent payload contains no extra personal data.

### E4-T3 — Detail data: show an event from list data
- **What**: `GetEventUseCase` served from the list/cache until `GET /events/{id}/` exists.
- **Tech**: Deep links (E7) need by-id fetch → add `[BE-blocked]` sub-step E4-T9. For now resolve from the in-memory feed result.
- **Test**: Repository test: found / not in cache → typed `NotFound`.
- **Depends on**: E3-T2
- **Human review**: Acceptable limitation for the pilot.

### E4-T4 — Screen: Event detail
- **What**: Title, category tag, date/time, place, description, organizer name (when available), map block, share button.
- **Tech**: Mockup `Dettaglio evento`. Map: coordinates come from the BE; **no client geocoding**. Map widget choice is an ADR (tile provider, privacy, cost). Share creates a link/text; real deep link in E7. Verified-organizer badge only when the BE provides it.
- **Test**: ViewModel states; widget test for missing optional fields (no end time, no org); goldens; semantics reading order.
- **Depends on**: E4-T3, E0-T6
- **Human review**: Map provider/privacy decision; fidelity to the mockup.

### E4-T5 — Screen: Create event form
- **What**: Fields title, category, date & time, place, description, "pubblica come" (citizen only until E6).
- **Tech**: Mockup bottom sheet. Local draft saved if the user leaves mid-way (BOOTSTRAP wireframe). Date/time pickers with time zone Europe/Rome. Address → coordinates stopgap: manual map pin or a geocoder behind a `Geocoder` interface (decide; server-side geocoding preferred later).
- **Test**: ViewModel tests (validation, draft restore, submit success/failure, double-tap submit guard); widget test of disabled/enabled publish.
- **Depends on**: E4-T2, E4-T1
- **Human review**: Draft storage (what is kept, for how long); geocoding choice and its privacy cost.

### E4-T6 — Flow: publish → feed
- **What**: After a successful publish, close the sheet, show a confirmation ("Pubblicato"), and the new event appears in the feed.
- **Tech**: Refresh the feed; no optimistic ordering hacks (order is the BE's).
- **Test**: Integration test with fake backend: create → feed shows it in BE order.
- **Depends on**: E4-T5, E3-T3
- **Human review**: Message wording; error recovery path.

### E4-T7 — [BE-blocked] Edit and cancel own events
- **What**: Edit form and "Annulla evento".
- **Tech**: Contract: `PATCH`, `cancel`. Changing date/place/organizer notifies subscribers (BE). Only the creator/org admin sees actions (UX hint; BE enforces).
- **Test**: ViewModel tests; permission-denied (403) handling; repository suite on fake+real.
- **Depends on**: BE edit/cancel; E4-T5
- **Human review**: Confirmation dialog copy for cancel.

### E4-T8 — [BE-blocked] Cover image and external links
- **What**: Optional image upload and links on create/detail.
- **Tech**: Upload contract needed (multipart or pre-signed). Client-side size/type validation, downscale before upload, strip EXIF location.
- **Test**: Validation tests (size, type); upload failure keeps the form data.
- **Depends on**: BE upload; E4-T5
- **Human review**: Privacy: EXIF stripping verified on a real photo.

### E4-T9 — [BE-blocked] Fetch event by id
- **What**: Replace E4-T3 with `GET /api/events/{id}/`.
- **Tech**: Needed for deep links and notifications.
- **Test**: Repository suite; 404 → `NotFound`.
- **Depends on**: BE detail endpoint
- **Human review**: —
