# Demokratia

Flutter app (single iOS + Android codebase) for Demokratia. Bundle / application id: `org.demokratia.app`. Minimum OS: iOS 15.0, Android API 24 (ADR 0006). Generated with Flutter 3.47.9 / Dart 3.13.7.

- Agent orchestration and architecture rules: `AGENTS.md`
- Development plan: `docs/plan/README.md`; decisions: `docs/adr/`
- UI source of truth: `docs/mockup/index.html`, `docs/mockup/design-system.html`

## Run

The Flutter app lives in `App/`; run all commands below from there (`cd App`).

```sh
flutter run --dart-define=FLAVOR=dev    # default when FLAVOR is omitted
flutter run --dart-define=FLAVOR=prod
```

## Checks

```sh
flutter analyze
flutter test   # includes test/architecture/import_boundaries_test.dart (layer import rules)
```
