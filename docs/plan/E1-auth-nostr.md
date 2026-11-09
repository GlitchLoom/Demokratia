# E1 — Authentication with Nostr

Goal: a citizen opens the app, gets a Nostr identity on the device, signs the BE challenge, and has a persistent, auto-refreshing session.
BE readiness: ✅ — `POST /api/auth/nostr/challenge/`, `POST /api/auth/nostr/login/`, `POST /api/auth/login/refresh/`, `GET /api/auth/me/`. **Prerequisite**: the Nostr code on the BE is currently uncommitted — confirm it is on the branch the client targets.
Agents: Data, Domain, Presentation, UI, Coordinator, Testing. New skill: `nostr-auth`.

**Protocol recap (BE rules)**: request a nonce (`201 {nonce, expires_at}`, single use, ~5 min TTL, throttled 20/min per IP). Build a Nostr event: `kind = 22242`, `tags = [["challenge", nonce]]`, `content = nonce`, `created_at`, `pubkey` = 64 lowercase hex x-only key, `id` = sha256 of the NIP-01 serialization `[0, pubkey, created_at, kind, tags, content]`, `sig` = BIP-340 Schnorr signature over `id`. `POST` it as `{"event": {...}}` → `200 {access, refresh, user}`. A new user is auto-created on first login. Access ≈ 5 min, refresh ≈ 1 day.

### E1-T1 — Align the docs with Nostr auth
- **What**: Update `docs/BOOTSTRAP.md` §6 (Onboarding/registration) and §9.1 (client auth) to describe Nostr login; note the product consequences (no email/phone recovery).
- **Tech**: Docs only. Also update the mockup copy later in E1-T5 if wording changes.
- **Test**: n/a. Review for consistency with §4 principle 4 (minimal data).
- **Depends on**: —
- **Human review**: **You approve the wording** — it is a product statement.

### E1-T2 — Nostr key management and signing (spike + library choice)
- **What**: Decide how the app generates, stores and uses a secp256k1 key and produces BIP-340 signatures.
- **Tech**: Use a vetted Dart secp256k1/Schnorr + sha256 library — **do not hand-roll crypto**. Evaluate maintenance, license, platform support. Private key lives only in secure storage (`flutter_secure_storage`: Keychain/Keystore). Consider an `AuthSigner` interface in `domain` so an external signer (e.g. NIP-55/NIP-46) can be added later. Output: ADR + a minimal proof signing a known test vector.
- **Test**: Unit test with official NIP-01 / BIP-340 test vectors (id computation and signature verification); the BE's own helper in `accounts/tests/nostr_helpers.py` shows what it accepts.
- **Depends on**: E0-T1
- **Human review**: **Security gate** — a person reviews the library, key handling and the ADR before anything builds on it.

### E1-T3 — Domain: `Identity`, `Session`, `AuthRepository`
- **What**: Entities (`Identity` = public key; `Session` = tokens + expiry + user), `AuthRepository` interface (`signIn`, `signOut`, `currentSession`, `refresh`), use cases `SignInUseCase`, `SignOutUseCase`, `RestoreSessionUseCase`.
- **Tech**: Pure Dart. Typed `AuthFailure` (challengeExpired, invalidSignature, rateLimited, network, unknown). `AuthSigner` is **out of scope** here: it is defined by the outcome of E1-T2 (security gate); `AuthRepository.signIn` must not depend on it in this task, E1-T4 wires signing.
- **Test**: Use-case tests with a fake repository covering success and each failure; sign-out clears the session.
- **Depends on**: E0-T2
- **Human review**: Failure types — they define the messages users will see.

### E1-T4 — Data: Nostr login API integration
- **What**: Implement `AuthRepository`: challenge → build event → sign → login → persist tokens.
- **Tech**: DTOs for `{nonce, expires_at}` and `{access, refresh, user}`; mapper to `Session`. Tokens in secure storage only. Retry once on `challengeExpired`. Map 429 to `rateLimited`. Event `created_at` = device time (clock skew: surface a clear error if the BE rejects it).
- **Test**: Repository tests against a fake `ApiClient` for the happy path and each error; a **contract test** against the local BE (dev-only) that performs a real login with a test key.
- **Depends on**: E1-T2, E1-T3, E0-T7
- **Human review**: Confirm nothing sensitive is logged; check the serialization matches NIP-01 exactly.

### E1-T5 — Session persistence and silent refresh
- **What**: Restore the session at startup; automatically refresh the access token before/after expiry; sign out when refresh fails.
- **Tech**: Interceptor on 401 → single in-flight refresh (queue concurrent requests) → retry once. Proactive refresh using the known ~5 min lifetime (decode `exp` from the JWT, no verification needed). Refresh token not rotated today — handle both cases (store a new one if returned). Skill: `secure-token-storage`.
- **Test**: Interceptor tests: concurrent 401s trigger exactly one refresh; refresh failure → sign-out event; expired refresh on cold start → signed-out state.
- **Depends on**: E1-T4
- **Human review**: Concurrency behavior; no refresh loops.

### E1-T6 — Screen: "Welcome / Create your identity"
- **What**: First-launch screen explaining the identity, with "Create identity" and "I already have a key".
- **Tech**: ViewModel states: idle, working, error. Copy in Italian, plain language, no jargon ("chiave" not "nsec" in the main flow). Mockup has no such screen → design it with existing components and show it before building.
- **Test**: ViewModel tests per state; widget test of the two actions; golden light/dark.
- **Depends on**: E1-T3, E0-T5
- **Human review**: **Design review** of the new screen and its copy.

### E1-T7 — Screen: key backup and recovery
- **What**: After creating an identity, show how to back up the key; screen to import an existing key.
- **Tech**: Show the key only on explicit action, behind OS authentication if available; block screenshots on the backup screen; copy-to-clipboard clears after a short time. Import validates format (hex / bech32) and derives the public key to confirm.
- **Test**: ViewModel tests for valid/invalid/malformed keys; verify the key never reaches logs or analytics; widget test for the reveal flow.
- **Depends on**: E1-T2, E1-T6
- **Human review**: **Security + product gate** — recovery policy (open question in the plan README).

### E1-T8 — Connect sign-in to the app flow
- **What**: Splash/launch decides: no session → Welcome; session → app. Sign-out from Profile returns to Welcome.
- **Tech**: Coordinator reacts to a session stream; deep-link restore comes in E7.
- **Test**: Coordinator tests for the three starting states; integration test: create identity → signed in → relaunch → still signed in (fake backend).
- **Depends on**: E1-T5, E1-T6, E0-T8
- **Human review**: Flow matches the mockup order (onboarding after auth).

### E1-T9 — Show the current user (`/me`)
- **What**: Load `GET /api/auth/me/` after login and expose `User` (id, email?, pubkey, isModerator).
- **Tech**: `email` is nullable; show a shortened public key as the display identity. `isModerator` enables moderation UI in E8 (client check is UX only; BE enforces).
- **Test**: Mapper test for null email; repository test; 401 → refresh path.
- **Depends on**: E1-T5
- **Human review**: How the identity is displayed (privacy).
