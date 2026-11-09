---
name: dart-async-streams-patterns
description: "Use when writing use cases, Repositories or ViewModels that use Future/async-await or Stream (cancellation, error handling, state streams)."
---

# dart-async-streams-patterns

Use of Future/async-await and Stream for use cases, Repositories and ViewModels.

## Checklist

- Repository interfaces and use cases expose Future<Result<T>> or Stream<T>, not callbacks
- ViewModels cancel subscriptions and timers in dispose() to avoid leaks and updates after destruction
- Independent network calls (e.g. event detail + related events) use Future.wait instead of sequential awaits
- Before calling notifyListeners()/emitting state after an await, check that the ViewModel has not been disposed

## Used by

domain-agent, data-agent, presentation-agent
