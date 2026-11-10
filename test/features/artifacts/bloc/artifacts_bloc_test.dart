import 'dart:async';
import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/features/artifacts/bloc/artifacts_bloc.dart';
import 'package:travel_buddy/features/artifacts/bloc/artifacts_state.dart';
import 'package:travel_buddy/logic/common/http_client.dart';
import 'package:travel_buddy/logic/data/collectible_data.dart';
import 'package:travel_buddy/logic/data/destination_type.dart';
import 'package:travel_buddy/logic/data/highlight_data.dart';

HttpResponse _ok(Map<String, dynamic> body) =>
    HttpResponse(statusCode: 200, body: jsonEncode(body));

HttpResponse _serverError() =>
    HttpResponse(statusCode: 503, body: '{}');

HttpResponse _notFound() =>
    HttpResponse(statusCode: 404, body: '{}');

Map<String, dynamic> _bodyForButrint() => {
      'highlights': [
        {'id': 'h-1', 'title': 'Highlight 1'},
        {'id': 'h-2', 'title': 'Highlight 2'},
      ],
      'collectibles': [
        {'id': 'c-1', 'title': 'Collectible 1'},
      ],
    };

Map<String, dynamic> _bodyForBerat() => {
      'highlights': [
        {'id': 'h-3', 'title': 'Highlight 3'},
      ],
      'collectibles': [],
    };

class _FakeHttp {
  int totalCallCount = 0;
  final Map<String, HttpResponse> _responses = {};
  final Map<String, int> _callsPerUrl = {};

  void respond(String urlSubstr, HttpResponse response) {
    _responses[urlSubstr] = response;
  }

  int callsForUrl(String urlSubstr) => _callsPerUrl[urlSubstr] ?? 0;

  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    totalCallCount++;
    for (final entry in _responses.entries) {
      if (url.contains(entry.key)) {
        _callsPerUrl[entry.key] = (_callsPerUrl[entry.key] ?? 0) + 1;
        return entry.value;
      }
    }
    return HttpResponse.error(NetErrorType.disconnected);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `Env.apiBaseUrl` reads from dotenv; seed test values so the URL builder
  // doesn't throw on `dotenv.env['API_BASE_URL']` access during fetch.
  setUpAll(() {
    dotenv.loadFromString(
      envString: 'API_BASE_URL=https://test.example.com',
      isOptional: true,
    );
  });

  late _FakeHttp http_;

  setUp(() {
    http_ = _FakeHttp();
    // Reset legacy global lists between tests so the side-effect assertions
    // don't see leftovers from a prior test.
    for (final t in DestinationType.values) {
      HighlightData.replaceForDestination(t, const []);
      CollectibleData.replaceForDestination(t, const []);
    }
  });

  ArtifactsBloc build() => ArtifactsBloc(httpGet: http_.get);

  test('initial state has empty maps and dataVersion=0', () async {
    final bloc = build();
    expect(bloc.state, const ArtifactsState());
    expect(bloc.state.byDestination, isEmpty);
    expect(bloc.state.byId, isEmpty);
    expect(bloc.state.dataVersion, 0);
    await bloc.close();
  });

  blocTest<ArtifactsBloc, ArtifactsState>(
    'getForDestination cache miss fetches, emits, populates state',
    setUp: () {
      http_.respond('/destinations/butrint/artifacts', _ok(_bodyForButrint()));
    },
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
      expect(http_.callsForUrl('/destinations/butrint/artifacts'), 1);
    },
  );

  test('getForDestination cache hit returns cached without fetching', () async {
    http_.respond('/destinations/butrint/artifacts', _ok(_bodyForButrint()));
    final bloc = build();
    final r1 = await bloc.getForDestination(DestinationType.butrint);
    expect(r1.highlights.length, 2);
    // Wait for the internal emit so cache is populated on state.
    await bloc.stream.firstWhere((s) => s.dataVersion > 0);
    expect(http_.callsForUrl('/destinations/butrint/artifacts'), 1);

    // Second call should hit the cache, not the network.
    final r2 = await bloc.getForDestination(DestinationType.butrint);
    expect(r2.highlights.length, 2);
    expect(http_.callsForUrl('/destinations/butrint/artifacts'), 1);
    await bloc.close();
  });

  test('no backend configured returns empty results without requesting', () async {
    final bloc = ArtifactsBloc(httpGet: http_.get, baseUrl: () => '');
    final result = await bloc.getForDestination(DestinationType.butrint);
    expect(result.highlights, isEmpty);
    expect(result.collectibles, isEmpty);
    expect(await bloc.getById('h-1'), isNull);
    expect(http_.totalCallCount, 0);
    expect(bloc.state.dataVersion, 0);
    await bloc.close();
  });

  test('parallel getForDestination calls dedupe to one fetch', () async {
    final completer = Completer<HttpResponse>();
    http_.respond('/destinations/butrint/artifacts', _ok(_bodyForButrint()));
    // Replace the fake http with one that holds the response until release.
    final bloc = ArtifactsBloc(httpGet: (url, {headers}) async {
      http_.totalCallCount++;
      return completer.future;
    });

    final f1 = bloc.getForDestination(DestinationType.butrint);
    final f2 = bloc.getForDestination(DestinationType.butrint);
    // Release the in-flight fetch.
    completer.complete(_ok(_bodyForButrint()));
    final r1 = await f1;
    final r2 = await f2;
    expect(r1.highlights.length, 2);
    expect(r2.highlights.length, 2);
    // Only one underlying fetch fired.
    expect(http_.totalCallCount, 1);
    await bloc.close();
  });

  test('getForDestination on transient 5xx returns empty without poisoning cache', () async {
    http_.respond('/destinations/butrint/artifacts', _serverError());
    final bloc = build();
    final result = await bloc.getForDestination(DestinationType.butrint);
    expect(result.highlights, isEmpty);
    expect(result.collectibles, isEmpty);
    // No state emit (no internal event fires for !ok).
    expect(bloc.state.byDestination[DestinationType.butrint], isNull);
    expect(bloc.state.dataVersion, 0);
    await bloc.close();
  });

  blocTest<ArtifactsBloc, ArtifactsState>(
    'successful fetch invokes the legacy global replaceForDestination',
    setUp: () {
      http_.respond('/destinations/butrint/artifacts', _ok(_bodyForButrint()));
    },
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
    http_.respond('/destinations/berat/artifacts', _ok(_bodyForBerat()));
    final bloc = build();
    await bloc.getForDestination(DestinationType.berat);
    expect(
      HighlightData.forDestination(DestinationType.berat).map((h) => h.id),
      ['h-3'],
    );
    await bloc.close();
  });

  test('a caller sharing an in-flight fetch also sees the filled lists', () async {
    final completer = Completer<HttpResponse>();
    final bloc = ArtifactsBloc(httpGet: (url, {headers}) => completer.future);
    final first = bloc.getForDestination(DestinationType.butrint);
    final second = bloc.getForDestination(DestinationType.butrint);
    completer.complete(_ok(_bodyForButrint()));
    await second;
    expect(HighlightData.forDestination(DestinationType.butrint).length, 2);
    expect(CollectibleData.forDestination(DestinationType.butrint).length, 1);
    await first;
    await bloc.close();
  });

  blocTest<ArtifactsBloc, ArtifactsState>(
    'getById cache miss fetches and emits new state',
    setUp: () {
      http_.respond(
        '/artifacts/x-1',
        _ok({'id': 'x-1', 'title': 'X-One'}),
      );
    },
    build: build,
    act: (b) async {
      final result = await b.getById('x-1');
      expect(result?.objectId, 'x-1');
      expect(result?.title, 'X-One');
    },
    verify: (b) {
      expect(b.state.byId['x-1']?.title, 'X-One');
    },
  );

  test('getById on 404 returns null without emitting', () async {
    http_.respond('/artifacts/missing', _notFound());
    final bloc = build();
    final result = await bloc.getById('missing');
    expect(result, isNull);
    expect(bloc.state.byId.containsKey('missing'), isFalse);
    await bloc.close();
  });

  blocTest<ArtifactsBloc, ArtifactsState>(
    'preloadAll fetches every destination and bumps dataVersion per success',
    setUp: () {
      // Stub two destinations to succeed; remaining default to disconnected.
      http_.respond('/destinations/butrint/artifacts', _ok(_bodyForButrint()));
      http_.respond('/destinations/berat/artifacts', _ok(_bodyForBerat()));
    },
    build: build,
    act: (b) async {
      await b.preloadAll();
    },
    verify: (b) {
      // Two successes => dataVersion bumped twice.
      expect(b.state.dataVersion, 2);
      expect(b.state.byDestination.length, 2);
      expect(b.state.byDestination.containsKey(DestinationType.butrint), isTrue);
      expect(b.state.byDestination.containsKey(DestinationType.berat), isTrue);
    },
  );
}
