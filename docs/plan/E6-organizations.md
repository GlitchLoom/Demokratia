# E6 — Organizations and follow

Goal: organizations have public profiles; citizens follow them; events can be published on behalf of an organization.
BE readiness: ❌ — no Organization, membership or Follow model. `Event` has no `organization` field (only `created_by`).
Agents: Domain, Data, Presentation, UI, Coordinator, Testing.

**Proposed contract**
- `GET /api/organizations/{id}/` → `{id, name, description, category, city, links[], logo, followers_count, events_count, active_since, verified}`
- `GET /api/organizations/{id}/events/` (same shape/ordering as the feed)
- `PUT|DELETE /api/organizations/{id}/follow/`
- `GET /api/me/organizations/` (those I administer) and `POST /api/organizations/` (create)
- `Event.organization` (id + name) in event payloads; `POST /api/events/` accepts `organization`.
- Followers are **count only**, never a list.

### E6-T1 — Domain: `Organization`, `Follow`, use cases
- **What**: Entities and `GetOrganization`, `FollowOrganization`, `UnfollowOrganization`, `GetMyOrganizations`, `GetOrganizationEvents`.
- **Tech**: `verified` is informational only — never used for ordering (BOOTSTRAP §4.2).
- **Test**: Use-case tests with fakes (follow idempotent, unfollow).
- **Depends on**: E3-T1
- **Human review**: Fields shown publicly.

### E6-T2 — Data: fake organization repository
- **What**: Fake repository seeded with the mockup data (Comitato Bologna Clima, 1284 followers…).
- **Tech**: Same shared repository suite as the future real one.
- **Test**: Shared suite.
- **Depends on**: E6-T1
- **Human review**: Fake excluded from release.

### E6-T3 — Screen: Organization profile
- **What**: Header, stats (followers count, events published, active since), Follow button, upcoming events in chronological order.
- **Tech**: Mockup `Organizzazione`. Pushed from the event detail organizer chip (Coordinator). Events use `EventCard`; same ordering as feed, no promoted items.
- **Test**: ViewModel states; goldens; semantics; follow optimistic update with rollback.
- **Depends on**: E6-T2, E4-T4, E0-T6
- **Human review**: No "popular" or boosted treatment anywhere.

### E6-T4 — Publish as organization
- **What**: In Create event, "Pubblica come" shows the user's organizations.
- **Tech**: Only appears if `GetMyOrganizations` is non-empty. Same fields for everyone (parity, BOOTSTRAP §4.2). Extend E4-T2's request DTO with `organization`.
- **Test**: ViewModel tests (no orgs → citizen only; with orgs → selector); request carries the id.
- **Depends on**: E6-T2, E4-T5
- **Human review**: Rate-limit differences are BE-side only; the UI shows none.

### E6-T5 — Create organization request
- **What**: Profile → "Crea la tua organizzazione" form (name, description, category, city, links, logo).
- **Tech**: Logo upload shares logic with E4-T8. A citizen can administer several organizations (many-to-many).
- **Test**: Validation tests; submit success/failure; form draft.
- **Depends on**: E6-T2, E8-T1
- **Human review**: Which fields are public by default.

### E6-T6 — [BE-blocked] Switch to the real organization API
- **What**: Real data sources + `organization` in event payloads.
- **Test**: Shared suite on real; contract test; 403 on publishing for an org the user doesn't administer.
- **Depends on**: BE organizations
- **Human review**: —
