/// Build flavor placeholder (E0-T2).
///
/// Selected at build time with `--dart-define=FLAVOR=dev|prod`; defaults to
/// [Flavor.dev] so a plain `flutter run` works. Per-flavor values (API base
/// URL, cleartext policy) are added in E0-T3; nothing environment-specific
/// lives here yet. Never put URLs, keys or secrets in this file.
enum Flavor {
  dev,
  prod;

  /// Value passed via `--dart-define=FLAVOR=...` at compile time.
  static const String _raw = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  /// The flavor this binary was compiled with.
  static Flavor fromEnvironment() => parse(_raw);

  /// Parses a flavor name; throws [ArgumentError] on unknown values so a typo
  /// in a build command fails loudly instead of silently shipping `dev`.
  static Flavor parse(String name) {
    for (final flavor in Flavor.values) {
      if (flavor.name == name) return flavor;
    }
    throw ArgumentError.value(
      name,
      'FLAVOR',
      'expected one of ${Flavor.values.map((f) => f.name).join(', ')}',
    );
  }
}
