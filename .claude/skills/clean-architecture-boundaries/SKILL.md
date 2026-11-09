---
name: clean-architecture-boundaries
description: "Use when adding or moving code across lib/domain, lib/data and lib/presentation, or verifying imports: domain depends on nothing; data and presentation depend on domain; no layer bypasses the interfaces defined in domain."
---

# clean-architecture-boundaries

Dependency rules between the domain/data/presentation layers: domain depends on nothing; data and presentation depend on domain; no layer bypasses the interfaces defined in domain.

## Checklist

- lib/domain does not import package:flutter, dio/http, drift/hive or other platform packages
- Concrete implementations (Repository, DataSource, mappers) live only in lib/data
- ViewModels in lib/presentation depend only on interfaces/use cases from lib/domain, never on DTOs or network/DB models
- No type defined in lib/data (DTOs, DB entities) crosses the boundary into presentation: always go through the domain entity
- The Coordinator navigates between screens; it contains no business logic

## Rationale

Consistent with docs/BOOTSTRAP.md §9.1: the frontend holds no critical business logic; that lives in the application domain, conceptually shared with the backend.

## Used by

domain-agent, data-agent, presentation-agent, coordinator-agent, testing-agent
