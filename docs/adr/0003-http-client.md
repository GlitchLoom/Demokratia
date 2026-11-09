# ADR 0003 — HTTP client

- **Status**: **Accepted** (by the project owner, 2026-11-07)
- **Task**: E0-T1 · **Date**: 2026-11-07

## Context
Backend is Django REST + SimpleJWT: access token ≈ 5 min, refresh ≈ 1 day, no rotation today. The client must refresh silently and serialize concurrent refreshes, map heterogeneous DRF error shapes to a domain `Failure` (E0-T7), apply timeouts, and never log `Authorization`. The `ApiClient` interface lives in `lib/data`; nothing HTTP-specific leaks to domain/presentation.

## Options considered
| Option | Pros | Cons | Testability | MVVM-C / layering fit |
|---|---|---|---|---|
| **A. `dio`** | Interceptors (incl. `QueuedInterceptor` for single-flight token refresh); per-request timeouts; cancel tokens; widely used | Larger API surface; one more dep | Very good: swap `HttpClientAdapter` for a fake in unit tests | Fine: confined to `lib/data` |
| B. `package:http` (Dart team) | Minimal, official; `MockClient` | Refresh queueing, retries, timeouts per call all hand-written | Very good | Fine |
| C. `dio` + `retrofit` | Typed API from annotations | Codegen; hides request details; little value with few endpoints | Good | Fine |
| D. `chopper` | Typed services, interceptors | Codegen; smaller community | Good | Fine |

## Recommendation
**A (`dio`)** without `retrofit`. One `ApiClient` interface in `lib/data` with a `DioApiClient` implementation; auth refresh via a `QueuedInterceptor` (proactive refresh from JWT `exp`, reactive on 401, retry once); errors mapped to domain `Failure` by status code (never by parsing the Italian messages). Logging interceptor in debug only, with headers redacted.

## Rejected alternatives
- **B**: viable and lighter, but the refresh/queueing logic we would write by hand is exactly what dio provides and tests well.
- **C/D**: codegen for a small number of endpoints is not worth it.

## Consequences
JSON (de)serialization approach (hand-written `fromJson` vs `json_serializable`) is a separate small decision — see open questions in the README.
