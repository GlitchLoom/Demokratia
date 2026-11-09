---
name: mvvm-c-pattern
description: "Use when creating or changing a screen's ViewModel, Coordinator or navigation wiring: how MVVM + Coordinator applies in this project (who owns state, who navigates, who calls use cases)."
---

# mvvm-c-pattern

How MVVM + Coordinator applies on Flutter in this project: who owns state, who navigates, who calls use cases.

## Checklist

- Every mockup screen (docs/mockup/index.html) has a dedicated ViewModel: Onboarding, Feed, Event detail, Create event, Organization, Notifications, Profile
- The widget is declarative: it listens to the state exposed by the ViewModel (ChangeNotifier/ValueNotifier or equivalent) and contains no navigation logic or use case calls
- The ViewModel does not know the concrete Coordinator: it exposes events/intents (e.g. a one-shot event stream) and the Coordinator decides where to navigate
- The Coordinator owns navigation (router, tabs, deep links); ViewModels and widgets never call Navigator/context.go directly
- "Parteciperò", feed filters and reminder toggles are always an explicit user commitment reflected in ViewModel state, never an automatic inference (docs/BOOTSTRAP.md §3)

## Used by

presentation-agent, coordinator-agent, ui-design-system-agent, domain-agent
