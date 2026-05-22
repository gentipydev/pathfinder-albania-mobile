import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_buddy/config/env.dart';
import 'package:travel_buddy/features/artifacts/bloc/artifacts_event.dart';
import 'package:travel_buddy/features/artifacts/bloc/artifacts_state.dart';
import 'package:travel_buddy/logic/common/http_client.dart';
import 'package:travel_buddy/logic/data/artifact_data.dart';
import 'package:travel_buddy/logic/data/collectible_data.dart';
import 'package:travel_buddy/logic/data/destination_artifacts.dart';
import 'package:travel_buddy/logic/data/destination_type.dart';
import 'package:travel_buddy/logic/data/highlight_data.dart';

typedef ArtifactsHttpFetcher =
    Future<HttpResponse> Function(String url, {Map<String, String>? headers});

/// Reactive cache for the backend's curated artifact catalog. Replaces the
/// legacy `ArtifactsLogic`. Public surface is methods-only — bloc state is
/// driven by internal events fired from the methods after a successful fetch.
///
/// Side effect on first fetch per destination: rebuilds the legacy
/// `HighlightData` / `CollectibleData` global lists so existing UI consumers
/// keep working synchronously after the first await. UI screens that render
/// before the fetch resolves should use a FutureBuilder against
/// `getForDestination`.
///
/// Only successful 2xx responses populate the cache and the legacy lists.
/// Transient failures (typically Render cold-starts) return empty results
/// to the caller without poisoning the cache, so subsequent mounts retry.
class ArtifactsBloc extends Bloc<ArtifactsEvent, ArtifactsState> {
  ArtifactsBloc({ArtifactsHttpFetcher? httpGet})
    : _httpGet = httpGet ?? HttpClient.get,
      super(const ArtifactsState()) {
    on<ArtifactsDestinationFetchedInternal>(_onDestinationFetched);
    on<ArtifactsByIdFetchedInternal>(_onByIdFetched);
  }

  final ArtifactsHttpFetcher _httpGet;

  static const _empty = DestinationArtifacts(
    highlights: [],
    collectibles: [],
  );

  // Dedupe in-flight fetches. Lifted from `artifacts_logic.dart:37,39`.
  final Map<DestinationType, Future<(bool, DestinationArtifacts)>>
  _inflightDestination = {};
  final Map<String, Future<ArtifactData?>> _inflightById = {};

  // ---- public methods (the only public surface) ----

  /// Returns artifacts for a destination from cache, or fetches them.
  /// On success, populates state, the legacy `HighlightData` /
  /// `CollectibleData` lists, and bumps `dataVersion`.
  Future<DestinationArtifacts> getForDestination(DestinationType type) async {
    final cached = state.byDestination[type];
    if (cached != null) return cached;

    final existing = _inflightDestination[type];
    if (existing != null) {
      final (_, result) = await existing;
      return result;
    }

    final future = _fetchDestination(type);
    _inflightDestination[type] = future;
    try {
      final (ok, result) = await future;
      if (ok) {
        add(ArtifactsDestinationFetchedInternal(type: type, result: result));
      }
      return result;
    } finally {
      _inflightDestination.remove(type);
    }
  }

  /// Synchronous read — null if not yet fetched.
  DestinationArtifacts? cachedFor(DestinationType type) =>
      state.byDestination[type];

  /// Single-artifact fetch with cache + dedupe. Used by deep-link details
  /// when the destination batch hasn't been loaded.
  Future<ArtifactData?> getById(String id) async {
    final cached = state.byId[id];
    if (cached != null) return cached;
    final inflight = _inflightById[id];
    if (inflight != null) return inflight;

    final future = _fetchById(id);
    _inflightById[id] = future;
    try {
      final result = await future;
      if (result != null) {
        add(ArtifactsByIdFetchedInternal(id: id, data: result));
      }
      return result;
    } finally {
      _inflightById.remove(id);
    }
  }

  /// Client-side keyword filter over cached destination artifacts. Backend
  /// has a search endpoint for when the catalog outgrows this approach.
  List<ArtifactData> searchInDestination(DestinationType type, String query) {
    final all = state.byDestination[type]?.all ?? const <ArtifactData>[];
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (a) => a.title.toLowerCase().contains(q) || a.keywords.contains(q),
        )
        .toList(growable: false);
  }

  /// Best-effort warm-up across every destination in parallel. Failures are
  /// swallowed; individual screens still re-fetch on mount.
  Future<void> preloadAll() async {
    await Future.wait(
      DestinationType.values.map((t) async {
        try {
          await getForDestination(t);
        } catch (e) {
          dev.log('artifactsBloc preload ${t.slug} failed: $e');
        }
      }),
    );
  }

  // ---- handlers (internal events drive emits) ----

  void _onDestinationFetched(
    ArtifactsDestinationFetchedInternal e,
    Emitter<ArtifactsState> emit,
  ) {
    final newByDestination = {...state.byDestination, e.type: e.result};
    final newById = {
      ...state.byId,
      for (final a in e.result.all) a.objectId: a,
    };
    HighlightData.replaceForDestination(e.type, e.result.highlights);
    CollectibleData.replaceForDestination(e.type, e.result.collectibles);
    emit(
      state.copyWith(
        byDestination: newByDestination,
        byId: newById,
        dataVersion: state.dataVersion + 1,
      ),
    );
  }

  void _onByIdFetched(
    ArtifactsByIdFetchedInternal e,
    Emitter<ArtifactsState> emit,
  ) {
    final newById = {...state.byId, e.id: e.data};
    emit(state.copyWith(byId: newById));
  }

  // ---- network ----

  Future<(bool, DestinationArtifacts)> _fetchDestination(
    DestinationType type,
  ) async {
    final url = '${Env.apiBaseUrl}/destinations/${type.slug}/artifacts';
    final response = await _httpGet(url);
    if (!response.success || response.body == null) {
      dev.log('artifactsBloc: ${type.slug} -> ${response.statusCode}');
      return (false, _empty);
    }
    try {
      final decoded = jsonDecode(response.body!) as Map<String, dynamic>;
      List<ArtifactData> parse(String key) =>
          (decoded[key] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(ArtifactData.fromJson)
              .toList(growable: false);
      return (
        true,
        DestinationArtifacts(
          highlights: parse('highlights'),
          collectibles: parse('collectibles'),
        ),
      );
    } on FormatException catch (e) {
      dev.log('artifactsBloc parse error: ${e.message}');
      return (false, _empty);
    }
  }

  Future<ArtifactData?> _fetchById(String id) async {
    final url = '${Env.apiBaseUrl}/artifacts/$id';
    final response = await _httpGet(url);
    if (!response.success || response.body == null) {
      dev.log('artifactsBloc byId $id -> ${response.statusCode}');
      return null;
    }
    try {
      final decoded = jsonDecode(response.body!) as Map<String, dynamic>;
      return ArtifactData.fromJson(decoded);
    } on FormatException catch (e) {
      dev.log('artifactsBloc byId parse error: ${e.message}');
      return null;
    }
  }
}
