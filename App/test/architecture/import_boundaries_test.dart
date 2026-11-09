// Import-boundary check for the Clean Architecture layers (E0-T2).
//
// Runs as a plain test with `flutter test`, so it needs no analyzer plugin and
// no extra dependency. Rules: .claude/rules/*.md and
// .claude/skills/clean-architecture-boundaries/SKILL.md.
@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _package = 'demokratia';

/// Pure-Dart third-party packages `lib/domain` may import. Empty on purpose:
/// adding one is a reviewed change.
const _domainAllowedPackages = <String>{};

/// SDK libraries that tie code to a platform or to Flutter.
const _domainForbiddenDartLibs = <String>{
  'dart:ui',
  'dart:io',
  'dart:ffi',
  'dart:html',
  'dart:js',
  'dart:js_interop',
  'dart:isolate',
  'dart:mirrors',
};

/// For each layer, the other `lib/` layers it must not import.
const _forbiddenLayers = <String, Set<String>>{
  'domain': {'data', 'presentation', 'coordinator', 'di', 'designsystem'},
  'data': {'presentation', 'coordinator', 'di', 'designsystem'},
  'presentation': {'data', 'di'},
  'designsystem': {'data', 'di'},
  'coordinator': {'data', 'di'},
};

final _directive = RegExp(
  r'''^\s*(?:import|export|part)\s+([^;]+);''',
  multiLine: true,
);
final _quoted = RegExp(r'''['"]([^'"]+)['"]''');

/// Returns the URIs referenced by import/export/part directives in [source]
/// (including conditional-import alternatives).
List<String> directiveUris(String source) => [
  for (final m in _directive.allMatches(source))
    for (final q in _quoted.allMatches(m.group(1)!)) q.group(1)!,
];

/// Resolves [uri] found in [file] (path relative to the repo root, using `/`)
/// to the top-level `lib/` layer it targets, or null if outside `lib/`.
String? targetLayer(String file, String uri) {
  String? libPath;
  if (uri.startsWith('package:$_package/')) {
    libPath = uri.substring('package:$_package/'.length);
  } else if (!uri.contains(':')) {
    final resolved = Uri.parse(file).resolve(uri).path;
    if (!resolved.startsWith('lib/')) return null;
    libPath = resolved.substring('lib/'.length);
  }
  if (libPath == null || !libPath.contains('/')) return null;
  return libPath.split('/').first;
}

/// Boundary violations for one file at [file] (repo-relative) in [layer].
List<String> violationsFor(String file, String layer, String source) {
  final problems = <String>[];
  for (final uri in directiveUris(source)) {
    final target = targetLayer(file, uri);
    if (target != null &&
        (_forbiddenLayers[layer]?.contains(target) ?? false)) {
      problems.add('$file: lib/$layer must not import lib/$target ("$uri")');
    }
    if (layer != 'domain') continue;
    if (uri.startsWith('dart:') && _domainForbiddenDartLibs.contains(uri)) {
      problems.add('$file: lib/domain must stay pure Dart ("$uri")');
    } else if (uri.startsWith('package:') &&
        !uri.startsWith('package:$_package/')) {
      final pkg = uri.substring('package:'.length).split('/').first;
      if (!_domainAllowedPackages.contains(pkg)) {
        problems.add(
          '$file: lib/domain must not depend on package "$pkg" ("$uri")',
        );
      }
    }
  }
  return problems;
}

void main() {
  test('lib/ layers respect the import boundaries', () {
    final problems = <String>[];
    for (final layer in _forbiddenLayers.keys) {
      final dir = Directory('lib/$layer');
      if (!dir.existsSync()) continue;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final file = entity.path.replaceAll(r'\', '/');
        problems.addAll(violationsFor(file, layer, entity.readAsStringSync()));
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  group('checker self-test', () {
    test('flags flutter, third-party and outer-layer imports in domain', () {
      const src = '''
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'dart:ui';
import 'package:demokratia/data/x.dart';
import '../presentation/y.dart';
import 'package:demokratia/domain/ok.dart';
import 'ok2.dart';
import 'dart:async';
// import 'package:flutter/material.dart';
''';
      expect(violationsFor('lib/domain/a.dart', 'domain', src), hasLength(5));
    });

    test('flags presentation importing data, allows domain', () {
      const src = '''
import 'package:demokratia/domain/e.dart';
import '../data/dto.dart';
import 'package:flutter/material.dart';
''';
      expect(
        violationsFor('lib/presentation/p.dart', 'presentation', src),
        hasLength(1),
      );
    });

    test('handles multi-line and conditional imports', () {
      const src = '''
import 'stub.dart'
    if (dart.library.io) 'package:demokratia/data/io.dart';
''';
      expect(violationsFor('lib/domain/a.dart', 'domain', src), hasLength(1));
    });
  });
}
