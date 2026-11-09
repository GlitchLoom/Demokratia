# E8 — Profile, privacy, reports

Goal: the citizen controls their data and preferences; anyone can report a problem; moderators have a minimal queue.
BE readiness: ✅ `GET /api/auth/me/` (includes `is_moderator`). ❌ everything else (export, deletion, reports, moderation queue). Django admin exists on the BE but is not a mobile API.
Agents: Domain, Data, Presentation, UI, Coordinator, Testing.

**Proposed contract**
- `GET /api/me/export/` (user's own data), `DELETE /api/me/` (account deletion / anonymization; GDPR).
- `POST /api/events/{id}/reports/` `{reason: "spam"|"illegal"|"false_info"|"violence", note?}` → `201` (never an automatic ban).
- Moderators: `GET /api/moderation/reports/`, `POST /api/moderation/reports/{id}/resolve/` `{action, note}`; actions change `Event.status`; audit log BE-side.

### E8-T1 — Screen: Profile shell
- **What**: "Il tuo profilo": followed cities, followed organizations (count), saved events (count), default reminders, actions.
- **Tech**: Mockup `Profilo`. Values read from existing use cases (E2, E5, E6); rows for not-yet-available data show "—", not fake numbers.
- **Test**: ViewModel tests for partially available data; goldens; semantics.
- **Depends on**: E1-T9, E0-T6
- **Human review**: Data export/delete are at the same level as other settings (BOOTSTRAP wireframe), not buried.

### E8-T2 — Manage cities, categories, default reminders
- **What**: Edit onboarding choices and default reminder thresholds from Profile.
- **Tech**: Reuses E2 use cases; default reminders feed E5-T4 initial selection.
- **Test**: ViewModel tests (changes persist; clearing all categories = unfiltered feed).
- **Depends on**: E8-T1, E2-T2, E5-T4
- **Human review**: —

### E8-T3 — Sign out and key management
- **What**: Sign out; "Backup key" (reuses E1-T7); "Delete local key" with a strong warning.
- **Tech**: Sign out unregisters the device token (E7-T4) and clears tokens, **not** the key unless asked. Deleting the key without a backup means losing the identity — double confirmation.
- **Test**: ViewModel tests for each path; verify secure storage state after each.
- **Depends on**: E8-T1, E1-T7
- **Human review**: **Security gate** — wording and confirmation steps.

### E8-T4 — Report an event
- **What**: "Segnala questo evento" opens a reason sheet and submits.
- **Tech**: Mockup button on detail. Reasons per BOOTSTRAP §6; confirmation says it goes to moderators. Contract-first on a fake.
- **Test**: ViewModel tests (submit, duplicate report, offline queue or clear error); semantics.
- **Depends on**: E4-T4
- **Human review**: Reasons list and copy (neutral, no accusation).

### E8-T5 — [BE-blocked] Data export and account deletion
- **What**: "Esporta i miei dati" and "Elimina account" flows.
- **Tech**: Export saves/shares a file (user-initiated). Deletion requires re-confirmation, calls BE, then wipes local data and key; show what is deleted vs anonymized (BE decides — note: event `created_by` currently CASCADE-deletes events).
- **Test**: Fake-backend tests; local wipe verified (tokens, cache, drafts, key).
- **Depends on**: BE export/deletion; E8-T3
- **Human review**: **Legal/privacy gate** — text and BE behavior (CASCADE) agreed.

### E8-T6 — [BE-blocked] Switch reports to the real API
- **Test**: Shared suite fake+real; contract test.
- **Depends on**: BE reports; E8-T4
- **Human review**: —

### E8-T7 — [BE-blocked] Moderator queue (minimal)
- **What**: If `is_moderator`, show a "Moderazione" entry with the reports list and resolve actions.
- **Tech**: Client check is UX only; BE enforces roles. Actions only on content rules (illegality, violence, spam, false facts) — no opinion-based moderation (BOOTSTRAP §4.3). Consider doing moderation in the web/admin instead of mobile — decide.
- **Test**: ViewModel tests; 403 for non-moderators; the entry is hidden when `is_moderator` is false.
- **Depends on**: BE moderation; E1-T9
- **Human review**: **Scope decision** — mobile vs admin-only moderation.
