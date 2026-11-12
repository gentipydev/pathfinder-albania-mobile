import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The showcase (everything in lib/ outside lib/agent/) must work without the
/// agent side, so it may never import it. Only the composition root, which
/// wires the agent in when APP_MODE=full, is allowed to.
const _compositionRoot = {
  'lib/main.dart',
  'lib/router.dart',
  'lib/logic/app_logic.dart',
};

/// Packages only the agent side uses (auth, chat, voice, trips, maps routing).
const _agentOnlyPackages = [
  'supabase_flutter',
  'speech_to_text',
  'flutter_tts',
  'siri_wave',
  'geolocator',
  'image_picker',
  'flutter_polyline_points',
  'flutter_markdown_plus',
];

/// `path → import line` for every showcase file line that matches [isOffending].
List<String> _showcaseLinesWhere(bool Function(String line) isOffending, {bool allowCompositionRoot = true}) {
  final offenders = <String>[];
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    final path = file.path.replaceAll(r'\', '/');
    if (path.startsWith('lib/agent/')) continue;
    if (allowCompositionRoot && _compositionRoot.contains(path)) continue;
    for (final line in file.readAsLinesSync()) {
      if (isOffending(line)) offenders.add('$path → ${line.trim()}');
    }
  }
  return offenders;
}

void main() {
  test('agent-only packages are used only inside lib/agent/', () {
    final offenders = _showcaseLinesWhere(
      (line) => _agentOnlyPackages.any((p) => line.contains('package:$p/')),
      allowCompositionRoot: false,
    );
    expect(offenders, isEmpty, reason: 'Use these packages from lib/agent/ only.');
  });

  test('showcase code never imports lib/agent/', () {
    final offenders = _showcaseLinesWhere((line) => line.contains('package:pathfinder_albania/agent/'));
    expect(
      offenders,
      isEmpty,
      reason:
          'Showcase files must not depend on the agent side. Move the code into lib/agent/, '
          'or wire it through lib/agent/agent_module.dart from the composition root.',
    );
  });
}
