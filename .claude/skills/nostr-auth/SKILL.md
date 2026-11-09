---
name: nostr-auth
description: "Use when working on Nostr login, key custody, challenge signing or session handling against the Demokratia backend. Plan reference: docs/plan/E1-auth-nostr.md."
---

# nostr-auth

Nostr-based login against the Demokratia backend: key custody on the device, challenge signing, and session handling. Plan reference: docs/plan/E1-auth-nostr.md.

## Checklist

- Flow: POST /api/auth/nostr/challenge/ → {nonce, expires_at}; build a Nostr event with kind 22242, tags [["challenge", nonce]], content equal to nonce; POST /api/auth/nostr/login/ with {"event": {id, pubkey, created_at, kind, tags, content, sig}} → {access, refresh, user}
- id is the sha256 of the NIP-01 serialization [0, pubkey, created_at, kind, tags, content]; sig is a BIP-340 Schnorr signature over id; pubkey is 64 lowercase hex (x-only)
- A challenge is single-use and short-lived (about 5 minutes): on expiry fetch a new one and retry once; the challenge endpoint is throttled (about 20/min per IP) so map 429 to a rate-limited failure
- Never hand-roll cryptography: use a vetted secp256k1/BIP-340 library chosen in the E1-T2 ADR, and verify with official test vectors
- The private key lives only in platform secure storage; it never appears in logs, crash reports, analytics, backups or clipboard history; reveal it only on explicit user action
- Expose signing through a domain interface (AuthSigner) so an external signer can be added later without touching use cases
- Access tokens last about 5 minutes and refresh tokens about 1 day (not rotated today): refresh proactively from the JWT exp claim and handle a rotated refresh token if the backend starts returning one
- Recovery is by key backup only (no email/phone reset): any flow that can delete the key needs a strong, double-confirmed warning
- Any change to this flow requires human security review before merge

## Source of truth

- `docs/plan/E1-auth-nostr.md`
- `docs/BOOTSTRAP.md`

## Used by

domain-agent, data-agent, presentation-agent, di-composition-agent, testing-agent
