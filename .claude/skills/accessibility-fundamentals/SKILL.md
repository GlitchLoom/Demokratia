---
name: accessibility-fundamentals
description: "Use when building or reviewing any UI component or screen: accessibility requirements (labels, contrast, tap targets, text scaling) as required by docs/BOOTSTRAP.md §9.1 ('a truly inclusive channel')."
---

# accessibility-fundamentals

Accessibility requirements for UI components, as required by docs/BOOTSTRAP.md §9.1 ('a truly inclusive channel').

## Checklist

- Widgets respect the system text scaling (MediaQuery.textScaler) without truncating or overlapping text
- Text/background contrast meets at least WCAG AA in both light and dark (Timbro Comunale palette)
- Every interactive element (buttons, chips, event cards) has a descriptive Semantics label, not just an icon
- VoiceOver/TalkBack read the state of toggles (e.g. active category chip, pressed 'Parteciperò') via Semantics (selected/toggled), not just through color

## Used by

ui-design-system-agent
