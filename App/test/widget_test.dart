import 'package:demokratia/di/flavor.dart';
import 'package:demokratia/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts on a blank page', (tester) async {
    await tester.pumpWidget(const DemokratiaApp(flavor: Flavor.dev));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });
}
