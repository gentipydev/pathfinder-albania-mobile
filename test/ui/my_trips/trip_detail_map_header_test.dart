import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/l10n/app_localizations.dart';
import 'package:travel_buddy/logic/locale_logic.dart';
import 'package:travel_buddy/ui/screens/buddy/widgets/itinerary_map_thumbnail.dart';
import 'package:travel_buddy/ui/screens/my_trips/widgets/trip_detail_map_header.dart';

import '../../helpers/widget_test_harness.dart';

Future<void> _ensureLocaleLogic() async {
  if (GetIt.I.isRegistered<LocaleLogic>()) return;
  final logic = LocaleLogic();
  await logic.loadIfChanged(const Locale('en'));
  GetIt.I.registerSingleton<LocaleLogic>(logic);
}

Trip _trip({String? staticMapUrl}) => Trip(
      id: 't1',
      title: 'Test trip',
      days: const [],
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      staticMapUrl: staticMapUrl,
    );

class _RecordingObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
  }
}

void main() {
  group('TripDetailMapHeader rendering', () {
    // NOTE: the "renders thumbnail when staticMapUrl is set" branch is
    // intentionally not covered here. `ItineraryMapThumbnail` mounts a
    // `CachedNetworkImage`, which initializes `flutter_cache_manager`
    // synchronously and calls `path_provider` + sqflite via platform
    // channels — none of which are stubbed in the widget-test harness. The
    // same trade-off is documented in `my_trips_screen_test.dart`; the
    // banner branch is covered there too via the fallback-row test below
    // plus manual visual verification on `flutter run`.

    testWidgets(
      'renders fallback button when staticMapUrl is null',
      (tester) async {
        await pumpLocalizedWidget(
          tester,
          TripDetailMapHeader(trip: _trip()),
        );
        expect(find.byType(ItineraryMapThumbnail), findsNothing);
        expect(find.text('View on map'), findsOneWidget);
        expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'renders fallback button when staticMapUrl is the empty string',
      (tester) async {
        await pumpLocalizedWidget(
          tester,
          TripDetailMapHeader(trip: _trip(staticMapUrl: '')),
        );
        expect(find.byType(ItineraryMapThumbnail), findsNothing);
        expect(find.text('View on map'), findsOneWidget);
      },
    );
  });

  group('TripDetailMapHeader navigation', () {
    testWidgets(
      'tapping the fallback button pushes a route',
      (tester) async {
        // Capture pushes without letting the destination mount. The
        // destination (TripMapScreen) wraps a GoogleMap which can't render
        // in widget tests; we assert the push happened, then bail before
        // the route transition advances enough to build it.
        await _ensureLocaleLogic();
        final observer = _RecordingObserver();
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorObservers: [observer],
            home: Scaffold(body: TripDetailMapHeader(trip: _trip())),
          ),
        );
        await tester.pump();
        // The initial pump pushed the home route — clear before tapping.
        observer.pushed.clear();

        await tester.tap(find.text('View on map'));
        // Single pump processes the tap and triggers Navigator.push. We
        // don't pump further — additional pumps would advance the route
        // transition and try to mount TripMapScreen (GoogleMap won't
        // render in widget tests).
        await tester.pump();

        expect(observer.pushed, hasLength(1));
        expect(observer.pushed.single, isA<PageRouteBuilder<dynamic>>());
      },
    );
  });
}
