---
name: responsive-layout-stability
description: "Use when writing or reviewing any widget or screen layout: every screen must be responsive and visually stable (no overflow, no layout jumps while the user interacts) on any phone size, orientation, text scale and system UI state."
---

# responsive-layout-stability

Rule of the project: the UI is **responsive and stable**. Nothing may resize, jump or overflow while the user interacts. A layout problem is a bug, not a polish item.

## Responsive (every size, every setting)

- Never hardcode screen sizes or positions. Layouts adapt via constraints (`LayoutBuilder`, `Flexible`/`Expanded`, `Wrap`, `ConstrainedBox`), not `MediaQuery` size math scattered in widgets. Breakpoints, if any, live in `lib/designsystem` as named tokens.
- Must work on: small phones (320x568), common phones (360x800, 390x844, 412x915), large phones, tablets/foldables, portrait and landscape, split-screen and resized windows.
- Text scale up to 2.0x and the system font-size/bold settings must not cause overflow (yellow-black stripes) or clipped/overlapping text. Long titles wrap or ellipsize deliberately (`maxLines` + `overflow`), never silently overflow.
- Respect safe areas, notches, status/navigation bars and the keyboard (`SafeArea`, `Scaffold.resizeToAvoidBottomInset`, scrollable forms). Content must never hide behind the keyboard, the FAB or the bottom nav.
- Any content that can grow (lists, forms, long descriptions, translations) lives in a scrollable. No fixed-height containers around text.
- Minimum tap target 48x48 dp even when the layout is tight.

## Stable (no movement while interacting)

- No layout shift: reserve space for async content (skeletons/placeholders with the same size as the final content), images with fixed aspect ratio (`AspectRatio`) and an error/placeholder state of the same size.
- Loading, empty, error and content states must not change the surrounding layout (header, nav, filters stay put).
- Toggling state (chips selected, "Parteciperò" pressed, counters changing) must not change the widget's size: same padding/border width, tabular figures or a fixed min-width for counters.
- Keyboard open/close, rotation, pull-to-refresh and font-size changes must not reset scroll position or user input.
- Animations are short and purposeful, never animate size changes of content the user is reading or tapping.
- Use `const`/stable keys on list items so rebuilds do not reorder or flicker (`ValueKey(event.id)`).

## Do not

- Do not use fixed `width`/`height` on text containers, `Positioned` with magic numbers, or `Expanded` inside unbounded parents (`ListView`, `Column` in a scroll view) without bounding them.
- Do not suppress overflow errors; fix the layout.

## Tests (required with every widget/screen task)

- Widget test pumps the widget at: 320x568, 390x844 and a tablet size (e.g. 800x1280), light and dark, text scale 1.0 and 2.0. Assert no exception (`tester.takeException()` is null, no `RenderFlex overflowed`).
- Landscape variant for full screens.
- For interactive widgets: assert the size (`tester.getSize`) is identical before and after toggling state and between loading and loaded states.
- Golden tests for the key sizes/scales; review them against `docs/mockup/index.html`.
- Manual check before the Human review point: small emulator + large emulator + rotation + 200% font size, reported in the task report.

## Used by

ui-design-system-agent, presentation-agent, testing-agent
