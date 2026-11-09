---
name: rest-api-consumption
description: "Use when calling the Python REST backend, writing DTOs/mappers or a Fake repository: no real OpenAPI spec exists yet, so start from the data model in docs/BOOTSTRAP.md §10 as a working hypothesis."
---

# rest-api-consumption

How the Data Agent consumes the Python REST backend: no real OpenAPI spec exists yet, so work starts from the data model in docs/BOOTSTRAP.md §10 as a working hypothesis.

## Checklist

- REST endpoints and contracts are hypotheses derived from docs/BOOTSTRAP.md §10 (User, Organization, Event, Subscription, Follow, Notification, Report, City/Area) until a real OpenAPI spec exists
- Every DTO has an explicit mapper to the corresponding domain entity — never expose the DTO beyond the data layer
- Network errors are mapped to a domain error type (sealed class/Result), not raw DioException, before reaching presentation
- The REST client is isolated behind an injectable interface, so it can be faked/mocked in tests (see testing-agent)
- No client-side ranking or reordering: the feed keeps the chronological order returned by the backend (docs/BOOTSTRAP.md §9.2)

## Current backend facts

- All routes are under /api/ with no version prefix; OpenAPI at /api/schema/ (Swagger UI at /api/schema/swagger-ui/) is generated at runtime — check it before relying on a field
- GET /api/events/ is public, returns a plain unpaginated array of published events ordered by start_at; the only filters are lat, lon and radius_km, which must be sent together (else 400 with a bare list of messages)
- POST /api/events/ takes lat/lon (write-only) but responses use latitude/longitude: use separate request and response DTOs
- Error shapes are the DRF defaults: {"detail": "..."}, {"field": ["msg"]}, a bare list for geo-filter errors and {"event": ...} for Nostr failures; messages are in Italian — branch on HTTP status, never on message text
- Event categories: manifestazione, corteo, assemblea, dibattito, raccolta_firme, culturale, sciopero, altro; statuses: pubblicato, sospeso, rimosso, cancellato; parse unknown values to a safe default
- Missing today (build against fakes, see docs/plan/): event detail/edit/cancel, cities, organizations, follow, participation, notifications, device tokens, reports, moderation, account export/deletion

## Open questions

When a real OpenAPI/GraphQL schema becomes available (docs/BOOTSTRAP.md §15, public v1), update this skill with the final contracts.

## Used by

data-agent
