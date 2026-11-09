import 'package:demokratia/di/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses known flavors', () {
    expect(Flavor.parse('dev'), Flavor.dev);
    expect(Flavor.parse('prod'), Flavor.prod);
  });

  test('rejects unknown flavors', () {
    expect(() => Flavor.parse('staging'), throwsArgumentError);
    expect(() => Flavor.parse(''), throwsArgumentError);
  });

  test('defaults to dev when FLAVOR is not defined', () {
    expect(Flavor.fromEnvironment(), Flavor.dev);
  });
}
