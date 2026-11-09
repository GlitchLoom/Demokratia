# ADR 0007 — Nostr crypto and secure storage libraries (candidate list only)

- **Status**: **Proposed — no decision.** The decision belongs to E1-T2 and its **security gate** (human review of library, key handling and ADR).
- **Task**: E0-T1 (list only) · **Date**: 2026-11-07

## Context
The app generates and custodies a secp256k1 key, computes NIP-01 event ids (sha256) and BIP-340 Schnorr signatures; private key and JWTs live only in platform secure storage. Do not hand-roll crypto. Signing goes through a domain `AuthSigner` interface so external signers can be added later.

## Candidates to evaluate in E1-T2 (maintenance, license, audits, platform support, test vectors)
| Need | Candidate | Notes to verify |
|---|---|---|
| Secure storage | `flutter_secure_storage` | Keychain/Keystore; already named in the plan; check Android API floor, iOS keychain accessibility and backup/sync options (E9) |
| sha256 | `crypto` (Dart team) | Standard, well maintained |
| BIP-340 Schnorr | `bip340` (pure Dart) | Small package from the Nostr ecosystem; check maintenance, review status, constant-time behavior |
| secp256k1 primitives | `pointycastle` | Mature; offers the curve but not BIP-340 directly — using it alone would mean hand-rolling Schnorr (avoid) |
| Native libsecp256k1 binding | FFI wrappers around Bitcoin Core's `libsecp256k1` (package to identify) | Best-reviewed implementation; adds native build complexity |
| Nostr toolkits | `nostr`, `dart_nostr`, `ndk` | Event building/serialization + signing; may pull in relay/websocket code we do not need |
| Key backup (E1-T7) | `bip39` / NIP-06 derivation, NIP-49 (encrypted `ncryptsec`) | Depends on the recovery policy (product decision) |
| External signer (later) | NIP-55 (Android signer apps, e.g. Amber), NIP-46 (remote signer) | Only behind `AuthSigner`; not for E1 |

No package names above are endorsed; all must be re-checked on pub.dev at E1-T2.
