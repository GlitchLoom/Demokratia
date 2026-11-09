# E5 — Participation and reminders

Goal: "Parteciperò" is an explicit commitment; the citizen chooses reminder thresholds; saved events work offline.
BE readiness: ❌ — no Subscription/Interest model or endpoints. Everything here is built contract-first on a fake.
Agents: Domain, Data, Presentation, UI, Testing.

**Proposed contract**
- `PUT /api/events/{id}/participation/` body `{status: "going"|"interested", reminders: ["1w","1d","1h"]}` → `200`; `DELETE` same path removes it.
- `GET /api/me/participations/` → list of `{event, status, reminders}` (feeds "Eventi salvati").
- Reminder scheduling is **server-side** (BOOTSTRAP §9.2); the client only sends thresholds.
- Event payload gains `participants_count` (aggregate only, no lists).

### E5-T1 — Domain: `Participation`, reminders, use cases
- **What**: Entities `Participation` (eventId, status, reminders), `ReminderThreshold` (`oneWeek, oneDay, oneHour`); use cases `SetParticipation`, `RemoveParticipation`, `UpdateReminders`, `GetMyParticipations`.
- **Tech**: Default reminders come from Profile defaults (E8) but are only *applied on the user's explicit join*.
- **Test**: Use-case tests: join → leave → rejoin; reminders independent of status; duplicates idempotent.
- **Depends on**: E3-T1
- **Human review**: Status set ("going" vs "interested") vs the mockup (only "Parteciperò").

### E5-T2 — Data: fake + local participation store
- **What**: `FakeParticipationRepository` (in-memory/local) behind the interface, so UI work proceeds.
- **Tech**: Persist locally so the demo survives restarts. Must pass the shared repository test suite that the real implementation will also pass.
- **Test**: The shared suite (idempotency, offline, ordering).
- **Depends on**: E5-T1
- **Human review**: Fake clearly marked and excluded from release builds.

### E5-T3 — Screen: "Parteciperò" button on detail
- **What**: Primary button toggling to the joined state; optimistic update with rollback on failure.
- **Tech**: Mockup: `Parteciperò` → joined style. Disabled while the request runs. Requires a session (else go to sign-in, E1).
- **Test**: ViewModel tests (optimistic success, failure rollback with message, rapid double tap); semantics (toggled state); golden joined/not joined.
- **Depends on**: E5-T2, E4-T4
- **Human review**: Rollback UX when offline.

### E5-T4 — Reminder chips on detail
- **What**: 1 week / 1 day / 1 hour chips, shown after joining.
- **Tech**: Changing a chip calls `UpdateReminders`; chips reflect server state after refresh. Local OS notifications are **not** scheduled by the client (server push, E7).
- **Test**: ViewModel tests (toggle, persisted per event, none selected allowed).
- **Depends on**: E5-T3
- **Human review**: Wording when notifications permission is off (link to E7-T2).

### E5-T5 — Screen: Saved events list
- **What**: "Eventi salvati" under Profile showing joined events.
- **Tech**: Reads `GetMyParticipations`; available offline from cache; chronological order.
- **Test**: ViewModel tests (empty, offline, a cancelled event shows its status).
- **Depends on**: E5-T2, E8-T1 (Profile shell) or a temporary entry point
- **Human review**: Cancelled/suspended events presentation.

### E5-T6 — [BE-blocked] Switch to real participation API
- **What**: Real data source for participation endpoints and `participants_count` on cards/detail.
- **Tech**: Display the aggregate count only; never lists of people.
- **Test**: Shared repository suite on real; contract test; 404/403/409 mapping.
- **Depends on**: BE participation; E5-T5
- **Human review**: Confirm no participant identity leaks in any payload.
