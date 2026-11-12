import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/features/artifacts/bloc/artifacts_bloc.dart';
import 'package:pathfinder_albania/features/artifacts/bloc/artifacts_state.dart';
import 'package:pathfinder_albania/logic/common/bundled_content.dart';
import 'package:pathfinder_albania/logic/data/collectible_data.dart';
import 'package:pathfinder_albania/logic/data/destination_type.dart';
import 'package:pathfinder_albania/logic/data/highlight_data.dart';

Map<String, dynamic> _butrint() => {
      'highlights': [
        {'id': 'h-1', 'title': 'Highlight 1'},
        {'id': 'h-2', 'title': 'Highlight 2'},
      ],
      'collectibles': [
        {'id': 'c-1', 'title': 'Collectible 1'},
      ],
    };

Map<String, dynamic> _berat() => {
      'highlights': [
        {'id': 'h-3', 'title': 'Highlight 3'},
      ],
      'collectibles': [],
    };

/// Stands in for the asset bundle: one text per asset key, counting reads.
class _FakeAssets {
  final Map<String, String> _texts = {};
  int reads = 0;

  void manifest(Map<String, dynamic> json) =>
      _texts[BundledContent.artifactsManifest] = jsonEncode(json);

  void manifestText(String text) => _texts[BundledContent.artifactsManifest] = text;

  Future<String> load(String key) async {
    reads++;
    final text = _texts[key];
    if (text == null) throw StateError('Unable to load asset: $key');
    return text;
  }
}

void main() {
  late _FakeAssets assets;

  setUp(() {
    assets = _FakeAssets();
    // Reset legacy global lists between tests so the side-effect assertions
    // don't see leftovers from a prior test.
    for (final t in DestinationType.values) {
      HighlightData.replaceForDestination(t, const []);
      CollectibleData.replaceForDestination(t, const []);
    }
  });

  ArtifactsBloc build() => ArtifactsBloc(loadAsset: assets.load);

  test('initial state has empty maps and dataVersion=0', () async {
    final bloc = build();
    expect(bloc.state, const ArtifactsState());
    expect(bloc.state.byDestination, isEmpty);
    expect(bloc.state.byId, isEmpty);
    expect(bloc.state.dataVersion, 0);
    await bloc.close();
  });

  blocTest<ArtifactsBloc, ArtifactsState>(
    'getForDestination cache miss reads the manifest, emits, populates state',
    setUp: () => assets.manifest({'butrint': _butrint()}),
    build: build,
    act: (b) async {
      final result = await b.getForDestination(DestinationType.butrint);
      expect(result.highlights.length, 2);
      expect(result.collectibles.length, 1);
    },
    verify: (b) {
      expect(b.state.dataVersion, 1);
      expect(b.state.byDestination[DestinationType.butrint], isNotNull);
      expect(b.state.byId.containsKey('h-1'), isTrue);
      expect(b.state.byId.containsKey('c-1'), isTrue);
      expect(assets.reads, 1);
    },
  );

  test('the manifest is read once for every destination and cache hit', () async {
    assets.manifest({'butrint': _butrint(), 'berat': _berat()});
    final bloc = build();
    final r1 = await bloc.getForDestination(DestinationType.butrint);
    expect(r1.highlights.length, 2);
    // Wait for the internal emit so the cache is populated on state.
    await bloc.stream.firstWhere((s) => s.dataVersion > 0);
    expect(assets.reads, 1);

    // Second call hits the cache; a different destination reuses the manifest.
    final r2 = await bloc.getForDestination(DestinationType.butrint);
    expect(r2.highlights.length, 2);
    final r3 = await bloc.getForDestination(DestinationType.berat);
    expect(r3.highlights.map((h) => h.objectId), ['h-3']);
    expect(assets.reads, 1);
    await bloc.close();
  });

  test('parallel getForDestination calls dedupe to one read', () async {
    final completer = Completer<String>();
    var loads = 0;
    final bloc = ArtifactsBloc(loadAsset: (_) {
      loads++;
      return completer.future;
    });

    final f1 = bloc.getForDestination(DestinationType.butrint);
    final f2 = bloc.getForDestination(DestinationType.butrint);
    completer.complete(jsonEncode({'butrint': _butrint()}));
    final r1 = await f1;
    final r2 = await f2;
    expect(r1.highlights.length, 2);
    expect(r2.highlights.length, 2);
    expect(loads, 1);
    await bloc.close();
  });

  test('a missing manifest returns empty without poisoning the cache, and the next call retries', () async {
    final bloc = build();
    final result = await bloc.getForDestination(DestinationType.butrint);
    expect(result.highlights, isEmpty);
    expect(result.collectibles, isEmpty);
    // No state emit (no internal event fires for !ok).
    expect(bloc.state.byDestination[DestinationType.butrint], isNull);
    expect(bloc.state.dataVersion, 0);
    expect(await bloc.getById('h-1'), isNull);

    assets.manifest({'butrint': _butrint()});
    final retried = await bloc.getForDestination(DestinationType.butrint);
    expect(retried.highlights.length, 2);
    expect(assets.reads, 3);
    await bloc.close();
  });

  test('a malformed manifest returns empty and leaves the legacy lists alone', () async {
    assets.manifestText('not json');
    final bloc = build();
    final result = await bloc.getForDestination(DestinationType.butrint);
    expect(result.highlights, isEmpty);
    expect(bloc.state.dataVersion, 0);
    expect(HighlightData.forDestination(DestinationType.butrint), isEmpty);
    await bloc.close();
  });

  test('a destination absent from the manifest returns empty', () async {
    assets.manifest({'butrint': _butrint()});
    final bloc = build();
    final berat = await bloc.getForDestination(DestinationType.berat);
    expect(berat.highlights, isEmpty);
    expect(bloc.state.byDestination.containsKey(DestinationType.berat), isFalse);
    await bloc.close();
  });

  blocTest<ArtifactsBloc, ArtifactsState>(
    'a successful read invokes the legacy global replaceForDestination',
    setUp: () => assets.manifest({'butrint': _butrint()}),
    build: build,
    act: (b) async {
      await b.getForDestination(DestinationType.butrint);
    },
    verify: (_) {
      expect(HighlightData.forDestination(DestinationType.butrint).length, 2);
      expect(CollectibleData.forDestination(DestinationType.butrint).length, 1);
    },
  );

  // The artifact carousel reads HighlightData right after awaiting
  // getForDestination, so the lists must already be filled when the await
  // returns, not later when the bloc handles its internal event.
  test('legacy lists are filled as soon as getForDestination returns', () async {
    assets.manifest({'berat': _berat()});
    final bloc = build();
    await bloc.getForDestination(DestinationType.berat);
    expect(
      HighlightData.forDestination(DestinationType.berat).map((h) => h.id),
      ['h-3'],
    );
    await bloc.close();
  });

  test('a caller sharing an in-flight read also sees the filled lists', () async {
    final completer = Completer<String>();
    final bloc = ArtifactsBloc(loadAsset: (_) => completer.future);
    final first = bloc.getForDestination(DestinationType.butrint);
    final second = bloc.getForDestination(DestinationType.butrint);
    completer.complete(jsonEncode({'butrint': _butrint()}));
    await second;
    expect(HighlightData.forDestination(DestinationType.butrint).length, 2);
    expect(CollectibleData.forDestination(DestinationType.butrint).length, 1);
    await first;
    await bloc.close();
  });

  blocTest<ArtifactsBloc, ArtifactsState>(
    'getById finds an artifact in any destination and emits new state',
    setUp: () => assets.manifest({'butrint': _butrint(), 'berat': _berat()}),
    build: build,
    act: (b) async {
      final result = await b.getById('h-3');
      expect(result?.objectId, 'h-3');
      expect(result?.title, 'Highlight 3');
    },
    verify: (b) {
      expect(b.state.byId['h-3']?.title, 'Highlight 3');
      expect(b.state.byDestination, isEmpty);
    },
  );

  test('getById for an unknown id returns null without emitting', () async {
    assets.manifest({'butrint': _butrint()});
    final bloc = build();
    final result = await bloc.getById('missing');
    expect(result, isNull);
    expect(bloc.state.byId.containsKey('missing'), isFalse);
    await bloc.close();
  });

  blocTest<ArtifactsBloc, ArtifactsState>(
    'preloadAll reads every listed destination and bumps dataVersion per success',
    setUp: () => assets.manifest({'butrint': _butrint(), 'berat': _berat()}),
    build: build,
    act: (b) async {
      await b.preloadAll();
    },
    verify: (b) {
      // Two destinations in the manifest => dataVersion bumped twice.
      expect(b.state.dataVersion, 2);
      expect(b.state.byDestination.length, 2);
      expect(b.state.byDestination.containsKey(DestinationType.butrint), isTrue);
      expect(b.state.byDestination.containsKey(DestinationType.berat), isTrue);
      expect(assets.reads, 1);
    },
  );

  group('the shipped snapshot manifest', () {
    // Reads the real asset from disk (tests run from the package root), so a
    // broken or incomplete snapshot fails here instead of on a device.
    Future<String> fromDisk(String key) => File(key).readAsString();

    test('has every destination, 37 artifacts, 8 collectibles, and every image file', () async {
      final bloc = ArtifactsBloc(loadAsset: fromDisk);
      await bloc.preloadAll();
      // The bloc records each destination through an internal event; let it run.
      await pumpEventQueue();
      expect(bloc.state.byDestination.length, DestinationType.values.length);
      final all = bloc.state.byDestination.values.expand((d) => d.all).toList();
      expect(all.length, 37);
      final collectibles = bloc.state.byDestination.values.expand((d) => d.collectibles).toList();
      expect(collectibles.length, 8);
      for (final a in all) {
        expect(a.objectId, isNotEmpty);
        expect(a.title, isNotEmpty);
        expect(a.image, startsWith('${BundledContent.root}/artifact-photos/'));
        expect(File(a.image).existsSync(), isTrue, reason: '${a.image} missing');
        expect(File(a.imageSmall).existsSync(), isTrue, reason: '${a.imageSmall} missing');
      }
      for (final c in collectibles) {
        expect(c.iconName, isNotEmpty, reason: '${c.objectId} has no icon');
        expect(File('assets/images/collectibles/${c.iconName}.png').existsSync(), isTrue,
            reason: 'no icon asset for ${c.iconName}');
      }
      await bloc.close();
    });
  });
}
