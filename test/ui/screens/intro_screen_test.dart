import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathfinder_albania/features/settings/bloc/settings_bloc.dart';
import 'package:pathfinder_albania/features/settings/bloc/settings_event.dart';
import 'package:pathfinder_albania/features/settings/bloc/settings_state.dart';
import 'package:pathfinder_albania/l10n/app_localizations.dart';
import 'package:pathfinder_albania/logic/locale_logic.dart';
import 'package:pathfinder_albania/ui/common/controls/app_page_indicator.dart';
import 'package:pathfinder_albania/ui/screens/intro/intro_screen.dart';

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

class _FakeSettingsEvent extends Fake implements SettingsEvent {}

/// iPhone SE: the smallest phone that gets the full-size layout.
const _phoneSe = Size(375, 647);

/// A short Android phone (640 dp minus status and navigation bars): compact layout.
const _phoneShort = Size(360, 568);

const _phoneLarge = Size(430, 880);

void main() {
  late _MockSettingsBloc bloc;

  setUpAll(() => registerFallbackValue(_FakeSettingsEvent()));

  setUp(() async {
    dotenv.loadFromString(envString: 'APP_MODE=showcase');
    bloc = _MockSettingsBloc();
    whenListen(bloc, const Stream<SettingsState>.empty(), initialState: const SettingsState(currentLocale: 'en'));
    if (!GetIt.I.isRegistered<LocaleLogic>()) {
      final logic = LocaleLogic();
      await logic.loadIfChanged(const Locale('en'));
      GetIt.I.registerSingleton<LocaleLogic>(logic);
    }
  });

  tearDown(() async {
    await GetIt.I<LocaleLogic>().loadIfChanged(const Locale('en'));
  });

  Future<void> pumpIntro(WidgetTester tester, {Size size = _phoneLarge, bool? includeAssistantPage}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (_, _) => Scaffold(body: IntroScreen(includeAssistantPage: includeAssistantPage)),
        ),
        GoRoute(path: '/home', builder: (_, _) => const Scaffold(body: Text('HOME'))),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<SettingsBloc>.value(
        value: bloc,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    // The intro fades in after a 500 ms delay.
    await tester.pump(const Duration(seconds: 2));
  }

  int pageCount(WidgetTester tester) => tester.widget<AppPageIndicator>(find.byType(AppPageIndicator)).count;

  testWidgets('showcase mode shows the three showcase pages, starting with the welcome', (tester) async {
    await pumpIntro(tester);
    expect(pageCount(tester), 3);
    expect(find.text('Meet Pathfinder Albania'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    // The intro is always English: no language picker.
    expect(find.text('English'), findsNothing);
    expect(find.text('Shqip'), findsNothing);
  });

  testWidgets('the assistant page is added when the agent side is on', (tester) async {
    await pumpIntro(tester, includeAssistantPage: true);
    expect(pageCount(tester), 4);
  });

  testWidgets('Skip completes onboarding and goes home', (tester) async {
    await pumpIntro(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    verify(() => bloc.add(const SettingsOnboardingCompletedToggled(true))).called(1);
    expect(find.text('HOME'), findsOneWidget);
  });

  for (final locale in ['en', 'sq']) {
    for (final size in [_phoneSe, _phoneShort]) {
      testWidgets('every page fits without overflow ($locale, ${size.width.toInt()}x${size.height.toInt()})', (
        tester,
      ) async {
        await GetIt.I<LocaleLogic>().loadIfChanged(Locale(locale));
        whenListen(bloc, const Stream<SettingsState>.empty(), initialState: SettingsState(currentLocale: locale));
        await pumpIntro(tester, size: size, includeAssistantPage: true);
        for (var page = 0; page < 3; page++) {
          await tester.drag(find.byType(PageView), Offset(-size.width, 0));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
