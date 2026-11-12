import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pathfinder_albania/features/artifacts/bloc/artifacts_event.dart';
import 'package:pathfinder_albania/features/artifacts/bloc/artifacts_state.dart';
import 'package:pathfinder_albania/logic/common/bundled_content.dart';
import 'package:pathfinder_albania/logic/data/artifact_data.dart';
import 'package:pathfinder_albania/logic/data/collectible_data.dart';
import 'package:pathfinder_albania/logic/data/destination_artifacts.dart';
import 'package:pathfinder_albania/logic/data/destination_type.dart';
import 'package:pathfinder_albania/logic/data/highlight_data.dart';

/// Reactive cache for the curated artifact catalog, read from the bundled
/// snapshot manifest ([BundledContent.artifactsManifest]). Public surface
/// is methods-only — bloc state is driven by internal events fired from the
/// methods after a successful read.
///
/// Side effect on first read per destination: rebuilds the legacy
/// `HighlightData` / `CollectibleData` global lists so existing UI consumers
/// keep working synchronously after the first await. UI screens that render
/// before the read resolves should use a FutureBuilder against
/// `getForDestination`.
///
/// Only a successfully parsed destination populates the cache and the legacy
/// lists. A missing or malformed manifest returns empty results to the
/// caller without poisoning the cache, so subsequent mounts retry.
class ArtifactsBloc extends Bloc<ArtifactsEvent, ArtifactsState> {
  ArtifactsBloc({
    AssetTextLoader? loadAsset,
    String manifestKey = BundledContent.artifactsManifest,
  })  : _loadAsset = loadAsset ?? BundledContent.loadString,
        _manifestKey = manifestKey,
        super(const ArtifactsState()) {
    on<ArtifactsDestinationFetchedInternal>(_onDestinationFetched);
    on<ArtifactsByIdFetchedInternal>(_onByIdFetched);
  }

  final AssetTextLoader _loadAsset;
  final String _manifestKey;

  static const _empty = DestinationArtifacts(
    highlights: [],
    collectibles: [],
  );

  /// The decoded manifest, read once. A failed read (missing or malformed
  /// asset) resolves to null and is not kept, so the next call retries.
  Future<Map<String, dynamic>?>? _manifest;

  // Dedupe in-flight reads.
  final Map<DestinationType, Future<(bool, DestinationArtifacts)>>
  _inflightDestination = {};
  final Map<String, Future<ArtifactData?>> _inflightById = {};

  // ---- public methods (the only public surface) ----

  /// Returns artifacts for a destination from cache, or reads them.
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

    // Fill the legacy lists inside the shared future, so they are ready the
    // moment any caller's await returns. The bloc's own event runs later.
    final future = _fetchDestination(type).then((fetched) {
      final (ok, result) = fetched;
      if (ok) {
        HighlightData.replaceForDestination(type, result.highlights);
        CollectibleData.replaceForDestination(type, result.collectibles);
      }
      return fetched;
    });
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

  /// Single-artifact lookup with cache + dedupe. Used by deep-link details
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

  /// Best-effort warm-up across every destination in parallel. Failures are
  /// swallowed; individual screens still re-read on mount.
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

  // ---- manifest ----

  Future<Map<String, dynamic>?> _readManifest() {
    final existing = _manifest;
    if (existing != null) return existing;
    late final Future<Map<String, dynamic>?> future;
    future = _loadManifest().then((manifest) {
      if (manifest == null && identical(_manifest, future)) _manifest = null;
      return manifest;
    });
    _manifest = future;
    return future;
  }

  Future<Map<String, dynamic>?> _loadManifest() async {
    try {
      final decoded = jsonDecode(await _loadAsset(_manifestKey));
      if (decoded is Map<String, dynamic>) return decoded;
      dev.log('artifactsBloc: manifest is not a JSON object');
      return null;
    } catch (e) {
      // Missing asset, invalid JSON, or an unexpected shape.
      dev.log('artifactsBloc: manifest read failed: $e');
      return null;
    }
  }

  Future<(bool, DestinationArtifacts)> _fetchDestination(
    DestinationType type,
  ) async {
    final manifest = await _readManifest();
    final entry = manifest?[type.slug];
    if (entry is! Map<String, dynamic>) {
      dev.log('artifactsBloc: no manifest entry for ${type.slug}');
      return (false, _empty);
    }
    try {
      List<ArtifactData> parse(String key) =>
          (entry[key] as List? ?? const [])
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
    } catch (e) {
      dev.log('artifactsBloc parse error for ${type.slug}: $e');
      return (false, _empty);
    }
  }

  Future<ArtifactData?> _fetchById(String id) async {
    final manifest = await _readManifest();
    if (manifest == null) return null;
    for (final entry in manifest.values) {
      if (entry is! Map<String, dynamic>) continue;
      for (final key in const ['highlights', 'collectibles']) {
        final list = entry[key];
        if (list is! List) continue;
        for (final item in list) {
          if (item is Map<String, dynamic> && item['id']?.toString() == id) {
            try {
              return ArtifactData.fromJson(item);
            } catch (e) {
              dev.log('artifactsBloc byId $id parse error: $e');
              return null;
            }
          }
        }
      }
    }
    dev.log('artifactsBloc byId $id -> not in manifest');
    return null;
  }
}
