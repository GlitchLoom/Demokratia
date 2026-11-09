---
name: flutter-widget-patterns
description: "Use when writing Flutter Design System widgets or screens: project conventions for composition, const widgets, state and theming."
---

# flutter-widget-patterns

Flutter conventions for Design System widgets and screens.

## Checklist

- Widgets are small and composable (one per mockup component: EventCard, CategoryChip, PrimaryButton, ...), not monolithic per-screen mega-widgets
- Prefer StatelessWidget; business state lives in the ViewModel, StatefulWidget only for purely local state (animations, focus, scroll controllers)
- Use const constructors where possible and split sub-widgets into classes instead of helper build methods, to reduce rebuilds
- Preview/golden sample data is consistent with the mockup (docs/mockup/index.html: 'Corteo per il clima', 'Comitato Bologna Clima', ...), not lorem ipsum
- Layouts must be responsive and stable (no overflow, no layout shifts): follow skill `responsive-layout-stability` for every widget and screen
- Navigation uses the router driven by the Coordinator, not Navigator.push called from screen widgets

## Used by

ui-design-system-agent, presentation-agent
