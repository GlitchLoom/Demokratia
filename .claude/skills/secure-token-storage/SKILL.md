---
name: secure-token-storage
description: "Use when storing or reading the session/refresh token (flutter_secure_storage: Keychain on iOS, Keystore on Android), as required by docs/BOOTSTRAP.md §9.1."
---

# secure-token-storage

Secure storage of the session token and refresh token (flutter_secure_storage: Keychain on iOS, Keystore on Android), as required by docs/BOOTSTRAP.md §9.1.

## Checklist

- Access and refresh tokens live in platform secure storage (flutter_secure_storage), never in shared_preferences or plain files on disk
- Silent token refresh is the Data Agent's responsibility (HTTP client interceptor), not of individual use cases or ViewModels
- An explicit logout invalidates and removes tokens from secure storage, not only from in-memory state
- No token or credential ends up in logs, even in debug builds

## Used by

data-agent, di-composition-agent
