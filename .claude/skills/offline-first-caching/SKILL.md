---
name: offline-first-caching
description: "Use when implementing the local cache for the feed and saved events (docs/BOOTSTRAP.md §9.1): show the last known feed offline, sync when back online."
---

# offline-first-caching

Lightweight local cache for the feed and saved events, as required by docs/BOOTSTRAP.md §9.1 (show the last known feed offline, sync when back online).

## Checklist

- The Repository returns cached data first (drift/hive/shared_preferences, if present) and then refreshes from the network, never the reverse
- A 'stale data' indicator is presentation's responsibility, but the information (last sync timestamp) is exposed by the data layer through the domain entity
- The cache is narrowly scoped (current feed, saved/subscribed events), not a generic database — avoid turning it into an all-purpose persistence layer nobody asked for
- No personal data beyond what is necessary is kept in cache longer than needed (consistent with docs/BOOTSTRAP.md §4.4, data minimization)

## Used by

data-agent
