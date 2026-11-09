---
paths:
  - "App/lib/domain/**"
---

- `lib/domain` is pure Dart: no `package:flutter`, `dio`/`http`, `drift`/`hive`, and no imports from `lib/data`, `lib/presentation`, `lib/coordinator`, `lib/di`.
- Repositories are abstract interfaces here; implementations live in `lib/data`.
