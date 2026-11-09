import 'package:flutter/material.dart';

import 'di/flavor.dart';

/// App entry point.
///
/// Placeholder until the composition root lands: E0-T3 adds per-flavor
/// configuration, the `AppContainer` (ADR 0005) wires the layers, and E0-T8
/// replaces the blank page with the root Coordinator.
void main() {
  final flavor = Flavor.fromEnvironment();
  runApp(DemokratiaApp(flavor: flavor));
}

/// Root widget: currently a blank page.
class DemokratiaApp extends StatelessWidget {
  const DemokratiaApp({super.key, required this.flavor});

  final Flavor flavor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demokratia',
      debugShowCheckedModeBanner: flavor == Flavor.dev,
      home: const Scaffold(body: SizedBox.shrink()),
    );
  }
}
