---
paths:
  - "App/lib/presentation/**"
  - "App/lib/designsystem/**"
  - "App/lib/coordinator/**"
---

- ViewModels depend on domain use cases only, never on `lib/data` types.
- Widgets contain no navigation calls (`Navigator`, `context.go`) and no use case calls.
- No hardcoded colors or fonts outside `lib/designsystem`.
- Layouts are responsive and stable: no overflow at any size, orientation or text scale up to 2.0x, no layout shifts while loading or interacting (see skill `responsive-layout-stability`).
- Feed order is whatever the backend returns: never re-rank or hide results client-side.
