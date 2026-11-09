---
name: design-token-translation
description: "Use when building the Flutter theme or reusable widgets from docs/mockup: translates the CSS tokens of design-system.html (Timbro Comunale palette) into a Flutter theme and the mockup components into widgets."
---

# design-token-translation

How to translate the CSS tokens of docs/mockup/design-system.html (Timbro Comunale palette) into a Flutter theme, and the mockup components into reusable widgets.

## Checklist

- Colors (--paper, --ink, --accent, --good, --warn, --danger, ...) become a ColorScheme plus a custom ThemeExtension (DemokratiaColors), with light/dark variants
- The type scale (serif for titles, sans for UI, mono for metadata/dates) becomes a TextTheme with semantic roles, not TextStyles hardcoded across widgets
- Each mockup component (event-card, chip, category tag, primary/ghost/joined button, notif-row, org-header, profile-row) becomes a reusable widget with the same semantic name
- Event categories keep the same color mapping as the mockup: corteo/manifestazione→warn, assemblea/dibattito→accent, civico/raccolta→good, sciopero/presidio→danger
- No hardcoded colors or fonts outside the designsystem module

## Source of truth

- `docs/mockup/index.html`
- `docs/mockup/design-system.html`

## Used by

ui-design-system-agent
