import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathfinder_albania/agent/features/preferences/bloc/preferences_bloc.dart';
import 'package:pathfinder_albania/agent/features/preferences/bloc/preferences_event.dart';
import 'package:pathfinder_albania/agent/features/preferences/bloc/preferences_state.dart';
import 'package:pathfinder_albania/agent/logic/preferences/preferences_service.dart';
import 'package:pathfinder_albania/agent/logic/preferences/user_preferences.dart';

class _MockPreferencesService extends Mock implements PreferencesService {}

class _FakeUserPrefs extends Fake implements UserPreferences {}

void main() {
  late _MockPreferencesService service;
  late String? token;

  setUpAll(() {
    registerFallbackValue(_FakeUserPrefs());
  });

  setUp(() {
    service = _MockPreferencesService();
    token = 'tok';
  });

  PreferencesBloc build() => PreferencesBloc(
        service: service,
        tokenReader: () => token,
      );

  group('PreferencesLoadRequested', () {
    final prefs = UserPreferences.defaults();

    blocTest<PreferencesBloc, PreferencesState>(
      'with token: emits isLoading then current populated',
      build: build,
      setUp: () {
        when(() => service.getMine(bearerToken: any(named: 'bearerToken')))
            .thenAnswer((_) async => prefs);
      },
      act: (b) => b.add(const PreferencesLoadRequested()),
      expect: () => [
        const PreferencesState(isLoading: true),
        PreferencesState(current: prefs, isLoading: false),
      ],
    );

    blocTest<PreferencesBloc, PreferencesState>(
      'with null token: no emits and no service call',
      build: build,
      setUp: () {
        token = null;
      },
      act: (b) => b.add(const PreferencesLoadRequested()),
      expect: () => const <PreferencesState>[],
      verify: (_) => verifyNever(
        () => service.getMine(bearerToken: any(named: 'bearerToken')),
      ),
    );

    blocTest<PreferencesBloc, PreferencesState>(
      'with empty token: no emits',
      build: build,
      setUp: () {
        token = '';
      },
      act: (b) => b.add(const PreferencesLoadRequested()),
      expect: () => const <PreferencesState>[],
    );

    blocTest<PreferencesBloc, PreferencesState>(
      'service throws: emits isLoading then lastError',
      build: build,
      setUp: () {
        when(() => service.getMine(bearerToken: any(named: 'bearerToken')))
            .thenThrow(Exception('boom'));
      },
      act: (b) => b.add(const PreferencesLoadRequested()),
      expect: () => const [
        PreferencesState(isLoading: true),
        PreferencesState(
          isLoading: false,
          lastError: 'Exception: boom',
        ),
      ],
    );

    blocTest<PreferencesBloc, PreferencesState>(
      'droppable: 2 rapid dispatches result in 1 service call',
      build: build,
      setUp: () {
        when(() => service.getMine(bearerToken: any(named: 'bearerToken')))
            .thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return prefs;
        });
      },
      act: (b) async {
        b.add(const PreferencesLoadRequested());
        b.add(const PreferencesLoadRequested());
        await Future<void>.delayed(const Duration(milliseconds: 60));
      },
      verify: (_) => verify(
        () => service.getMine(bearerToken: any(named: 'bearerToken')),
      ).called(1),
    );
  });

  group('PreferencesSaveRequested', () {
    final original = UserPreferences.defaults();
    final updated = original.copyWith(budget: 'luxury');

    blocTest<PreferencesBloc, PreferencesState>(
      'happy path: emits isSaving then current = updated',
      build: build,
      setUp: () {
        when(() => service.save(any(),
                bearerToken: any(named: 'bearerToken')))
            .thenAnswer((_) async {});
      },
      act: (b) => b.add(PreferencesSaveRequested(updated)),
      expect: () => [
        const PreferencesState(isSaving: true),
        PreferencesState(current: updated, isSaving: false),
      ],
    );

    blocTest<PreferencesBloc, PreferencesState>(
      'service throws: emits isSaving then lastError, current unchanged',
      build: build,
      setUp: () {
        when(() => service.save(any(),
                bearerToken: any(named: 'bearerToken')))
            .thenThrow(Exception('save failed'));
      },
      seed: () => PreferencesState(current: original),
      act: (b) => b.add(PreferencesSaveRequested(updated)),
      expect: () => [
        PreferencesState(current: original, isSaving: true),
        PreferencesState(
          current: original,
          isSaving: false,
          lastError: 'Exception: save failed',
        ),
      ],
    );
  });

  group('PreferencesGeneratePersonaRequested', () {
    final base = UserPreferences.defaults();

    blocTest<PreferencesBloc, PreferencesState>(
      'with current null: service still called, current stays null',
      build: build,
      setUp: () {
        when(() => service.generatePersona(
                bearerToken: any(named: 'bearerToken')))
            .thenAnswer((_) async => 'persona text');
      },
      act: (b) => b.add(const PreferencesGeneratePersonaRequested()),
      expect: () => const [
        PreferencesState(isGeneratingPersona: true),
        PreferencesState(),
      ],
      verify: (_) => verify(
        () => service.generatePersona(
              bearerToken: any(named: 'bearerToken'),
            ),
      ).called(1),
    );

    blocTest<PreferencesBloc, PreferencesState>(
      'happy path: emits generating then current.travelPersona = persona',
      build: build,
      setUp: () {
        when(() => service.generatePersona(
                bearerToken: any(named: 'bearerToken')))
            .thenAnswer((_) async => 'A free spirit who loves trails.');
      },
      seed: () => PreferencesState(current: base),
      act: (b) => b.add(const PreferencesGeneratePersonaRequested()),
      expect: () => [
        isA<PreferencesState>()
            .having((s) => s.isGeneratingPersona,
                'isGeneratingPersona', true)
            .having((s) => s.current, 'current', base),
        isA<PreferencesState>()
            .having((s) => s.isGeneratingPersona,
                'isGeneratingPersona', false)
            .having((s) => s.current?.travelPersona, 'persona',
                'A free spirit who loves trails.'),
      ],
    );

    blocTest<PreferencesBloc, PreferencesState>(
      'service throws: emits generating then lastError',
      build: build,
      setUp: () {
        when(() => service.generatePersona(
                bearerToken: any(named: 'bearerToken')))
            .thenThrow(Exception('persona failed'));
      },
      seed: () => PreferencesState(current: base),
      act: (b) => b.add(const PreferencesGeneratePersonaRequested()),
      expect: () => [
        PreferencesState(current: base, isGeneratingPersona: true),
        PreferencesState(
          current: base,
          isGeneratingPersona: false,
          lastError: 'Exception: persona failed',
        ),
      ],
    );
  });

  group('PreferencesCleared', () {
    final prefs = UserPreferences.defaults();

    blocTest<PreferencesBloc, PreferencesState>(
      'resets state to defaults',
      build: build,
      seed: () => PreferencesState(
        current: prefs,
        lastError: 'some error',
      ),
      act: (b) => b.add(const PreferencesCleared()),
      expect: () => const [PreferencesState()],
    );
  });
}
