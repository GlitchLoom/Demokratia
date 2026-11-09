# E7 — Notifications, push, deep links

Goal: reminders and updates arrive in time; the notification center keeps history; links open the right screen.
BE readiness: ❌ — no Notification model, no device token endpoint, no push dispatch.
Agents: DI & Composition, Domain, Data, Presentation, UI, Coordinator, Testing.

**Only three reasons to notify** (BOOTSTRAP §6 / wireframe): subscription reminders, new event from a followed organization, change/cancellation of an event I joined. No engagement notifications, no unread-count badge designed to drive returns.

**Proposed contract**
- `POST /api/me/devices/` `{platform:"ios"|"android", token}` / `DELETE /api/me/devices/{id}/`
- `GET /api/me/notifications/` (cursor) → `{id, type:"reminder"|"new_event"|"event_changed", event_id, title, created_at, read_at}`; `POST /api/me/notifications/{id}/read/`
- Push payload carries only `{type, event_id, notification_id}` — details fetched after tap (no sensitive text in the push).

### E7-T1 — Push setup (Firebase) in the Flutter project
- **What**: Integrate `firebase_messaging` for FCM (Android) and APNs through FCM (iOS).
- **Tech**: Firebase project and APNs key are **yours to create** (agents must not handle credentials). Native config files stay out of git if they hold secrets, or are documented. Foreground/background/terminated handlers registered in `di/`.
- **Test**: Manual: receive a console test push in all three app states on a real device (emulators are unreliable for APNs).
- **Depends on**: E0-T2
- **Human review**: **Credentials and privacy gate** — what Firebase collects; no analytics enabled.

### E7-T2 — Notification permission flow
- **What**: Ask for permission at a meaningful moment (after the first "Parteciperò"), explain why, handle denial.
- **Tech**: `NotificationPermissionService` interface in `domain`. iOS asks once → provide a "open settings" path. Android 13+ runtime permission.
- **Test**: ViewModel tests for granted/denied/permanently denied; the app never nags.
- **Depends on**: E7-T1, E5-T3
- **Human review**: Copy and timing.

### E7-T3 — Domain: `AppNotification` and use cases
- **What**: Entity, `GetNotifications`, `MarkNotificationRead`, `RegisterDevice`, `UnregisterDevice`.
- **Test**: Use-case tests with fakes.
- **Depends on**: E3-T1
- **Human review**: Notification types fixed to the three above.

### E7-T4 — [BE-blocked] Data: device token registration
- **What**: Register the token after sign-in and on token refresh; unregister on sign-out.
- **Tech**: Idempotent; retry with backoff; do not register before permission.
- **Test**: Fake-backend tests for each lifecycle event (login, token refresh, logout, permission revoked).
- **Depends on**: BE devices endpoint; E7-T2, E1-T5
- **Human review**: Token stored only where needed.

### E7-T5 — Screen: Notification center
- **What**: List with read/unread dot, relative time, tap opens the event.
- **Tech**: Mockup `Notifiche`. No numeric badge on the tab. Fake data source first (seed from mockup), real later.
- **Test**: ViewModel states (empty, offline, mark read), semantics (unread state announced), goldens.
- **Depends on**: E7-T3, E0-T6
- **Human review**: Absence of badge counters and urgency copy.

### E7-T6 — Deep links (links and push taps)
- **What**: `https://…/events/{id}` (and a custom scheme) opens Event detail; push tap opens the referenced event; unknown/removed event shows a clear message.
- **Tech**: Android App Links + iOS Universal Links need a domain and association files hosted by the BE/web (**dependency**). Coordinator parses links into routes and handles cold start vs warm start. Requires `GET /events/{id}/` (E4-T9). Not-signed-in users see the event (read-only) after link open.
- **Test**: Coordinator tests with link fixtures (valid, malformed, unknown id); integration test for cold/warm start routing.
- **Depends on**: E4-T9, E0-T8, domain + hosting decision
- **Human review**: **Security gate** — link parsing must never execute or trust unexpected params.

### E7-T7 — [BE-blocked] Real notifications API
- **What**: Switch the center to `GET /api/me/notifications/`.
- **Test**: Shared suite on fake+real; pagination; read-state sync (local first, sync later).
- **Depends on**: BE notifications; E7-T5
- **Human review**: —

### E7-T8 — End-to-end reminder check
- **What**: Manual scenario: join an event with a 1-hour reminder → push arrives on time → tap → detail.
- **Tech**: Checklist run on iOS and Android real devices; record time delta.
- **Test**: This *is* the test: document results in the PR.
- **Depends on**: E7-T4, E7-T6, E5-T6
- **Human review**: You run it.
