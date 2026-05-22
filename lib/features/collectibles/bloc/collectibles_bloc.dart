import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_buddy/features/artifacts/bloc/artifacts_bloc.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_event.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_state.dart';
import 'package:travel_buddy/logic/common/save_load_mixin.dart';
import 'package:travel_buddy/logic/data/collectible_data.dart';
import 'package:travel_buddy/logic/native_widget_service.dart';

/// Persistent collection state — which collectibles the user has
/// discovered, explored, or not yet found. Replaces the legacy
/// `CollectiblesLogic`.
///
/// Persists `state.statesById` to SharedPreferences via the
/// `ThrottledSaveLoadMixin` (2-second debounce). The `'collectibles.dat'`
/// filename is preserved verbatim so existing user data continues to load.
class CollectiblesBloc extends Bloc<CollectiblesEvent, CollectiblesState>
    with ThrottledSaveLoadMixin {
  CollectiblesBloc({
    NativeWidgetService? nativeWidget,
    ArtifactsBloc Function()? artifactsBlocProvider,
  }) : _nativeWidget = nativeWidget ?? GetIt.I<NativeWidgetService>(),
       _artifactsBlocProvider =
           artifactsBlocProvider ?? (() => GetIt.I<ArtifactsBloc>()),
       super(const CollectiblesState()) {
    unawaited(_nativeWidget.init());
    on<CollectiblesLoadRequested>(_onLoad, transformer: droppable());
    on<CollectiblesStateChanged>(_onStateChanged, transformer: sequential());
    on<CollectiblesResetRequested>(_onReset, transformer: sequential());
    on<CollectiblesFlushPendingSaveRequested>(
      _onFlushPendingSave,
      transformer: sequential(),
    );
  }

  final NativeWidgetService _nativeWidget;
  final ArtifactsBloc Function() _artifactsBlocProvider;

  // Stash from `copyFromJson` (called synchronously from the mixin's
  // `load()`); consumed inside `_onLoad` to feed an emit.
  Map<String, dynamic>? _pendingLoad;

  // ---- ThrottledSaveLoadMixin overrides ----

  @override
  String get fileName => 'collectibles.dat';

  @override
  Map<String, dynamic> toJson() => state.statesById;

  @override
  void copyFromJson(Map<String, dynamic> value) {
    _pendingLoad = value;
  }

  // ---- public convenience methods ----

  /// Bootstrap convenience: dispatches the load event and awaits it via a
  /// `Completer`. Mirrors `auth_bloc.dart`'s `refreshAccessToken` precedent.
  Future<void> loadFromPersistence() {
    final c = Completer<void>();
    add(CollectiblesLoadRequested(completer: c));
    return c.future;
  }

  /// Lifecycle convenience: matches the call site in `app_logic.dart`'s
  /// `_flushPendingSaves` so a backgrounded-then-killed app doesn't drop
  /// the user's last toggle.
  Future<void> flushPendingSaveAwaitable() {
    final c = Completer<void>();
    add(CollectiblesFlushPendingSaveRequested(completer: c));
    return c.future;
  }

  // ---- handlers ----

  Future<void> _onLoad(
    CollectiblesLoadRequested e,
    Emitter<CollectiblesState> emit,
  ) async {
    try {
      await load(); // mixin: SharedPreferences read → copyFromJson → fills _pendingLoad
      final loaded = _pendingLoad ?? const <String, dynamic>{};
      _pendingLoad = null;

      final states = <String, int>{};
      for (final c in collectiblesData) {
        final raw = loaded[c.id];
        states[c.id] = (raw is int) ? raw : CollectibleState.lost;
      }

      final discovered = states.values
          .where((v) => v == CollectibleState.discovered)
          .length;
      final explored = states.values
          .where((v) => v == CollectibleState.explored)
          .length;

      emit(
        state.copyWith(
          statesById: states,
          discoveredCount: discovered,
          exploredCount: explored,
          isLoaded: true,
        ),
      );

      await _persistFoundCountToWidget(discovered + explored);
    } finally {
      e.completer?.complete();
    }
  }

  Future<void> _onStateChanged(
    CollectiblesStateChanged e,
    Emitter<CollectiblesState> emit,
  ) async {
    final states = {...state.statesById, e.id: e.state};

    final discovered = states.values
        .where((v) => v == CollectibleState.discovered)
        .length;
    final explored = states.values
        .where((v) => v == CollectibleState.explored)
        .length;

    emit(
      state.copyWith(
        statesById: states,
        discoveredCount: discovered,
        exploredCount: explored,
      ),
    );

    if (e.state == CollectibleState.discovered) {
      final data = collectiblesData.firstWhereOrNull((o) => o.id == e.id);
      if (data != null) {
        unawaited(
          _updateNativeHomeWidgetData(
            title: data.title,
            id: data.id,
            imageUrl: data.imageUrlSmall,
          ),
        );
      }
    }

    await _persistFoundCountToWidget(discovered + explored);
    await scheduleSave();
  }

  Future<void> _onReset(
    CollectiblesResetRequested e,
    Emitter<CollectiblesState> emit,
  ) async {
    final states = <String, int>{
      for (final c in collectiblesData) c.id: CollectibleState.lost,
    };
    unawaited(_updateNativeHomeWidgetData());
    emit(
      state.copyWith(
        statesById: states,
        discoveredCount: 0,
        exploredCount: 0,
      ),
    );
    await _persistFoundCountToWidget(0);
    await scheduleSave();
  }

  Future<void> _onFlushPendingSave(
    CollectiblesFlushPendingSaveRequested e,
    Emitter<CollectiblesState> emit,
  ) async {
    try {
      await flushPendingSave();
    } finally {
      e.completer?.complete();
    }
  }

  // ---- private helpers (lifted from collectibles_logic.dart:99-123) ----

  Future<void> _updateNativeHomeWidgetData({
    String title = '',
    String id = '',
    String imageUrl = '',
  }) async {
    if (!_nativeWidget.isSupported) return;
    await _nativeWidget.save<String>('lastDiscoveredTitle', title);
    String subTitle = '';
    if (id.isNotEmpty) {
      final artifactData = await _artifactsBlocProvider().getById(id);
      subTitle = artifactData?.date ?? '';
    }
    await _nativeWidget.save<String>('lastDiscoveredSubTitle', subTitle);
    // TODO(rebrand): restore the http.readBytes fetch once Albanian
    // collectible artwork is hosted on our own CDN. Currently `imageUrl`
    // resolves to the upstream Wonderous proxy (www.wonderous.info) which
    // 404s from this fork, so we skip the fetch and leave the home widget
    // image empty.
    String imageBase64 = '';
    await _nativeWidget.save<String>('lastDiscoveredImageData', imageBase64);
    await _nativeWidget.markDirty();
  }

  Future<void> _persistFoundCountToWidget(int total) async {
    await _nativeWidget.save<int>('discoveredCount', total);
    await _nativeWidget.markDirty();
  }
}
