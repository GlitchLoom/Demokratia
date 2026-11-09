# Demokratia — Flutter development & integration plan

> Status: v0.1 — living document. Scope: the **Flutter client** only (iOS + Android from one codebase). Backend work is tracked elsewhere; here it appears only as **dependencies**.

## 1. Where we start

**Backend** (`Demokratia-BE`, branch `test-nostr`): a Milestone-1 skeleton — Django 5.2 + DRF, PostgreSQL/PostGIS, SimpleJWT, Nostr login, `/me`, event list/create with geo radius filter.
**Client**: nothing yet. The UI/UX source of truth is the clickable mockup (`docs/mockup/index.html`, `docs/mockup/design-system.html`, Timbro Comunale palette). The agent layer lives in ``.

### Backend readiness matrix (what the client can rely on today)

| Capability | BE status | Notes |
|---|---|---|
| Nostr challenge + login (`POST /api/auth/nostr/challenge/`, `/nostr/login/`) | ✅ | Not committed yet on the BE (untracked files) — **confirm it is merged before E1** |
| Token refresh (`POST /api/auth/login/refresh/`) | ✅ | Access token ≈ 5 min, refresh ≈ 1 day, no rotation |
| Current user (`GET /api/auth/me/`) | ✅ | `{id, email, nostr_pubkey, is_moderator}` |
| Event list (`GET /api/events/`) | ⚠️ | Unpaginated array; only `lat`+`lon`+`radius_km` filters (all three together); published only; ordered by `start_at` |
| Event create (`POST /api/events/`) | ✅ | `lat`/`lon` are write-only, response uses `latitude`/`longitude`; no image, no links, no organization |
| Event detail / edit / cancel / delete / history | ❌ | |
| Cities/areas, onboarding preferences | ❌ | |
| Organizations, follow | ❌ | |
| Join ("Parteciperò") + reminders | ❌ | |
| Notifications + push device token | ❌ | |
| Reports / moderation | ❌ | |
| Account export / deletion | ❌ | |
| OpenAPI | ✅ | `/api/schema/` (runtime), Swagger at `/api/schema/swagger-ui/` |

Other facts that shape the client: no `/v1` prefix; DRF default error format (`{"field": ["msg"]}`, `{"detail": "..."}`, a bare list for geo-filter errors, `{"event": ...}` for Nostr failures); error messages in Italian; CORS irrelevant for mobile.

## 2. Decisions already taken

- **Flutter only.** The whole repository is the Flutter project; there are no separate native iOS/Android codebases or agent folders.
- **Nostr is the intended citizen auth.** The app generates and custodies a Nostr key on the device. `docs/BOOTSTRAP.md` §6 (email/phone + password) is outdated → task `E1-T1`.
- **Backend gaps are dependencies, not tasks.** A task that needs a missing endpoint is marked **BE-blocked** and is built *contract-first* against a fake repository (see §4).

## 3. Epics

| Epic | Flow | BE readiness | File |
|---|---|---|---|
| E0 | Foundation: project, architecture, design system, networking | ✅ | [E0-foundation.md](E0-foundation.md) |
| E1 | Authentication with Nostr | ✅ (merge pending) | [E1-auth-nostr.md](E1-auth-nostr.md) |
| E2 | Onboarding (city + categories) | ❌ cities | [E2-onboarding.md](E2-onboarding.md) |
| E3 | Feed (chronological, explicit filters) | ⚠️ | [E3-feed.md](E3-feed.md) |
| E4 | Event detail + create/edit | ⚠️ create only | [E4-event.md](E4-event.md) |
| E5 | Participation + reminders | ❌ | [E5-participation.md](E5-participation.md) |
| E6 | Organizations + follow | ❌ | [E6-organizations.md](E6-organizations.md) |
| E7 | Notifications + push + deep links | ❌ | [E7-notifications.md](E7-notifications.md) |
| E8 | Profile, privacy, reports | ❌ except `/me` | [E8-profile-privacy-moderation.md](E8-profile-privacy-moderation.md) |
| E9 | Hardening: offline, accessibility, CI, release | n/a | [E9-hardening-release.md](E9-hardening-release.md) |

Suggested order: E0 → E1 → E3 → E4 (create) → E2 → E5 → E6 → E7 → E8 → E9. E3/E4 come early because the BE already supports them; everything after depends on BE delivery.

## 4. How we work (vibecoding with human control)

**Task rules**
- A task is **atomic and self-contained**: one agent-sized change, mergeable alone, with its own tests. If it needs two PRs, split it.
- **One task per request** to the agent. The request names the task ID (e.g. "Do E3-T2") — the orchestrator (`AGENTS.md`) reads the task and routes it.
- Epics group tasks by *flow*: API integration first, then each screen, then edge cases.
- Task IDs: `E<epic>-T<n>`. Never renumber; append new tasks.

**Task template** (every task in the epic files uses it)
- **What** — what to do, in user terms.
- **Tech** — technical guidance, layers touched, agents involved.
- **Test** — what must be tested (and how).
- **Depends on** — tasks and BE capabilities.
- **Human review** — the specific thing a human must look at before merge.

**Definition of Done (all tasks)**
1. Code respects layer boundaries (`.claude/skills/clean-architecture-boundaries/SKILL.md`).
2. Tests listed in the task exist and pass; `flutter analyze` is clean.
3. UI matches the mockup (or the deviation is written in the PR) and is responsive and stable: widget tests at small/normal/tablet sizes and text scale 1.0×/2.0× with no overflow, no layout shift while loading or interacting (`.claude/skills/responsive-layout-stability/SKILL.md`).
4. No secrets/tokens in logs; no hardcoded colors/fonts outside `designsystem`.
5. A human has done the **Human review** step. The agent stops and reports; it does not self-merge.

**Human gates (where a person must decide, not the agent)**
- Architectural choices (state management, router, DB) — recorded as ADRs in E0.
- Anything touching crypto/key custody (E1).
- Any contract deviation from the BE or a proposed new contract.
- Visual deviations from the mockup.
- Privacy-relevant data (what is cached, what is sent to the BE, push payloads).

**Contract-first for BE-blocked tasks**
1. The epic file states a **proposed contract** (endpoints + payloads). It is a proposal until the BE publishes it in OpenAPI.
2. Build domain + presentation against a `Fake…Repository`. The UI is demoable without the BE.
3. When the BE ships, swap in the real data source and run the **contract test** task of that epic. The fake and the real implementation must pass the same repository test suite.

**Product guardrails that tests must enforce** (from `docs/BOOTSTRAP.md` §4/§8)
- No client-side re-ranking or hiding: the feed shows the order the BE returns.
- "Parteciperò", filters and reminders are explicit user actions — never inferred.
- Followers are shown as a count only.
- No analytics/ad SDKs; minimal data; no engagement badges or dark patterns.

## 5. Open questions for the team

1. BE: when will the Nostr work be committed to `main`? (untracked files today)
2. BE: pagination style (cursor, as BOOTSTRAP §9.2 hints) and event-detail endpoint shape.
3. BE: access token lifetime of ~5 minutes — intended for mobile? Refresh rotation/blacklist?
4. Nostr key backup/recovery policy for citizens (E1-T7) — product decision.
5. Push provider details (FCM for both platforms via `firebase_messaging`?) — confirm in E7.
6. Moderation on mobile or admin-only (E8-T7).
7. Deep-link domain and hosting of the association files (E7-T6).
