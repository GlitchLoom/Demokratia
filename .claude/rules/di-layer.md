---
paths:
  - "App/lib/di/**"
---

- `lib/di` is the only place allowed to import from every layer: it wires `domain` interfaces to `data` implementations and builds ViewModels/Coordinators.
- No business logic here: only registration, environment/flavor config and push registration.
- Never hard-code secrets, API keys or production URLs; read them from flavor config or CI secrets.
- Platform-specific code (push, permissions) stays behind `domain` interfaces implemented in `lib/data`.
