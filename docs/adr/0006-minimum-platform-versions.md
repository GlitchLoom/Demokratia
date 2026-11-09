# ADR 0006 — Minimum iOS / Android versions

- **Status**: **Accepted** (2026-11-07) — plugin minimums to be re-verified in E0-T2
- **Task**: E0-T1 · **Date**: 2026-11-07

## Context
Toolchain: Flutter 3.32.8 / Dart 3.8.1. A civic app should reach as many citizens as possible (older devices included), but needs reliable hardware-backed secure storage for the Nostr private key and tokens (Keychain / Android Keystore), and push via `firebase_messaging` (E7). Known plugin floors (to re-verify at E0-T2 against current plugin versions): `flutter_secure_storage` requires Android API 23+; FlutterFire/Firebase iOS SDK requires iOS 13+; Flutter 3.32 itself supports iOS 12+ and Android API 21+.

## Options considered
| Option | Pros | Cons |
|---|---|---|
| A. Flutter defaults (iOS 12 / API 21) | Widest reach | Below plugin floors (secure storage, Firebase); old Keystore implementations are buggy; more devices to test |
| B. iOS 13 / API 23 (plugin floors) | Maximum reach the chosen plugins allow | Android 6 Keystore quirks; iOS 13–14 devices hard to test; extra test matrix |
| **C. iOS 15 / API 24 (Android 7.0)** | Covers the large majority of active devices (verify current share); more consistent Keystore/Keychain behavior; API 24 matches newer Flutter default floors | Excludes a small tail of very old devices |
| D. iOS 16 / API 26 | Simplest test matrix; modern APIs (e.g. notification channels on 26 by default) | Excludes noticeably more citizens, against the inclusiveness goal |

Testability: a lower floor means more emulator/simulator targets in manual QA; no impact on unit/widget tests. No impact on MVVM-C.

## Recommendation
**C — iOS 15.0, Android `minSdk` 24**; `targetSdk`/`compileSdk` = the level Google Play requires at release time (update in E9). Verify the current OS adoption numbers before accepting.

## Rejected alternatives
- **A**: incompatible with required plugins.
- **B**: marginal reach gain for higher security/test risk on key custody.
- **D**: unnecessary exclusion of older devices.

## Consequences
Set in E0-T2 (`ios/Podfile`, Xcode deployment target, `android/app/build.gradle(.kts)`).
