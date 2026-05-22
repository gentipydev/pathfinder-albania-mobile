import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/features/artifacts/bloc/artifacts_bloc.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_bloc.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_event.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_state.dart';
import 'package:travel_buddy/logic/data/artifact_data.dart';
import 'package:travel_buddy/logic/data/collectible_data.dart';
import 'package:travel_buddy/logic/data/destination_type.dart';
import 'package:travel_buddy/logic/native_widget_service.dart';

class _MockNativeWidget extends Mock implements NativeWidgetService {}

class _MockArtifactsBloc extends Mock implements ArtifactsBloc {}

ArtifactData _artifact(String id, {String title = 'Test'}) => ArtifactData(
      objectId: id,
      title: title,
      image: '',
      imageSmall: '',
      imageMedium: '',
      date: '',
      period: '',
      country: '',
      medium: '',
      dimension: '',
      classification: '',
      culture: '',
      objectType: '',
      objectBeginYear: 0,
      objectEndYear: 0,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockNativeWidget nativeWidget;
  late _MockArtifactsBloc artifactsBloc;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    nativeWidget = _MockNativeWidget();
    artifactsBloc = _MockArtifactsBloc();

    when(() => nativeWidget.isSupported).thenReturn(true);
    when(() => nativeWidget.init()).thenAnswer((_) async {});
    when(() => nativeWidget.save<int>(any(), any()))
        .thenAnswer((_) async => true);
    when(() => nativeWidget.save<String>(any(), any()))
        .thenAnswer((_) async => true);
    when(() => nativeWidget.markDirty()).thenAnswer((_) async => true);

    when(() => artifactsBloc.getById(any())).thenAnswer((_) async => null);

    // Reset the static `_byDestination` map between tests, then seed two
    // collectibles for Butrint.
    for (final t in DestinationType.values) {
      CollectibleData.replaceForDestination(t, const []);
    }
    CollectibleData.replaceForDestination(
      DestinationType.butrint,
      [
        _artifact('col-1', title: 'Vase A'),
        _artifact('col-2', title: 'Vase B'),
      ],
    );
  });

  CollectiblesBloc build() => CollectiblesBloc(
        nativeWidget: nativeWidget,
        artifactsBlocProvider: () => artifactsBloc,
      );

  test('initial state is empty and not loaded', () async {
    final bloc = build();
    expect(bloc.state, const CollectiblesState());
    expect(bloc.state.isLoaded, isFalse);
    expect(bloc.state.statesById, isEmpty);
    await bloc.close();
  });

  group('CollectiblesLoadRequested', () {
    blocTest<CollectiblesBloc, CollectiblesState>(
      'with empty SharedPreferences emits all-lost map and isLoaded:true',
      build: build,
      act: (b) => b.add(const CollectiblesLoadRequested()),
      verify: (b) {
        expect(b.state.isLoaded, isTrue);
        expect(b.state.statesById, {
          'col-1': CollectibleState.lost,
          'col-2': CollectibleState.lost,
        });
        expect(b.state.discoveredCount, 0);
        expect(b.state.exploredCount, 0);
      },
    );

    blocTest<CollectiblesBloc, CollectiblesState>(
      'with persisted JSON populates known IDs and drops orphans',
      setUp: () {
        SharedPreferences.setMockInitialValues({
          'collectibles.dat': jsonEncode({
            'col-1': CollectibleState.discovered,
            'col-orphan': CollectibleState.discovered,
          }),
        });
      },
      build: build,
      act: (b) => b.add(const CollectiblesLoadRequested()),
      verify: (b) {
        expect(b.state.statesById, {
          'col-1': CollectibleState.discovered,
          'col-2': CollectibleState.lost,
        });
        expect(b.state.statesById.containsKey('col-orphan'), isFalse);
        expect(b.state.discoveredCount, 1);
        expect(b.state.exploredCount, 0);
        expect(b.state.isLoaded, isTrue);
      },
    );

    test('loadFromPersistence completes after the emit', () async {
      final bloc = build();
      await bloc.loadFromPersistence();
      expect(bloc.state.isLoaded, isTrue);
      await bloc.close();
    });
  });

  group('CollectiblesStateChanged', () {
    blocTest<CollectiblesBloc, CollectiblesState>(
      'discovered triggers native widget title update and bumps count',
      build: build,
      seed: () => const CollectiblesState(
        statesById: {
          'col-1': CollectibleState.lost,
          'col-2': CollectibleState.lost,
        },
        isLoaded: true,
      ),
      act: (b) => b.add(const CollectiblesStateChanged(
        id: 'col-1',
        state: CollectibleState.discovered,
      )),
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        verify(
          () => nativeWidget.save<String>('lastDiscoveredTitle', 'Vase A'),
        ).called(1);
        verify(
          () => nativeWidget.save<int>('discoveredCount', 1),
        ).called(1);
      },
    );

    blocTest<CollectiblesBloc, CollectiblesState>(
      'explored does not trigger title update but bumps count',
      build: build,
      seed: () => const CollectiblesState(
        statesById: {
          'col-1': CollectibleState.lost,
          'col-2': CollectibleState.lost,
        },
        isLoaded: true,
      ),
      act: (b) => b.add(const CollectiblesStateChanged(
        id: 'col-1',
        state: CollectibleState.explored,
      )),
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        verifyNever(
          () => nativeWidget.save<String>('lastDiscoveredTitle', any()),
        );
        verify(
          () => nativeWidget.save<int>('discoveredCount', 1),
        ).called(1);
      },
    );

    blocTest<CollectiblesBloc, CollectiblesState>(
      'two sequential changes derive counts coherently',
      build: build,
      seed: () => const CollectiblesState(isLoaded: true),
      act: (b) {
        b.add(const CollectiblesStateChanged(
          id: 'col-1',
          state: CollectibleState.discovered,
        ));
        b.add(const CollectiblesStateChanged(
          id: 'col-2',
          state: CollectibleState.explored,
        ));
      },
      verify: (b) {
        expect(b.state.discoveredCount, 1);
        expect(b.state.exploredCount, 1);
        expect(b.state.statesById, {
          'col-1': CollectibleState.discovered,
          'col-2': CollectibleState.explored,
        });
      },
    );
  });

  blocTest<CollectiblesBloc, CollectiblesState>(
    'CollectiblesResetRequested zeros counts and clears widget',
    build: build,
    seed: () => const CollectiblesState(
      statesById: {
        'col-1': CollectibleState.discovered,
        'col-2': CollectibleState.explored,
      },
      discoveredCount: 1,
      exploredCount: 1,
      isLoaded: true,
    ),
    act: (b) => b.add(const CollectiblesResetRequested()),
    verify: (b) {
      expect(b.state.statesById, {
        'col-1': CollectibleState.lost,
        'col-2': CollectibleState.lost,
      });
      expect(b.state.discoveredCount, 0);
      expect(b.state.exploredCount, 0);
      verify(() => nativeWidget.save<int>('discoveredCount', 0)).called(1);
    },
  );

  test('flushPendingSaveAwaitable completes', () async {
    final bloc = build();
    await bloc.loadFromPersistence();
    bloc.add(const CollectiblesStateChanged(
      id: 'col-1',
      state: CollectibleState.discovered,
    ));
    await bloc.flushPendingSaveAwaitable();
    // Completer firing is the contract this test enforces; SharedPreferences
    // mock is in-memory so no on-disk verification is needed.
    await bloc.close();
  });
}
