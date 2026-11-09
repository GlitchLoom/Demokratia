---
paths:
  - "App/lib/data/**"
---

- DTOs never leave `lib/data`: always map to domain entities.
- Separate request and response DTOs when field names differ (e.g. `lat`/`lon` vs `latitude`/`longitude`).
- Never log `Authorization` headers, tokens or keys.
