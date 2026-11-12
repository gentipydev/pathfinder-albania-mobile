import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_error_mapper.dart';
import 'package:pathfinder_albania/agent/services/trip_service.dart';

void main() {
  group('mapTripsError', () {
    test('401 -> signIn', () {
      expect(
        mapTripsError(TripServiceException(401, 'unauth')),
        TripsErrorKey.signIn,
      );
    });

    test('404 -> notFound', () {
      expect(
        mapTripsError(TripServiceException(404, 'gone')),
        TripsErrorKey.notFound,
      );
    });

    test('409 without trip_limit_reached body -> conflict', () {
      expect(
        mapTripsError(TripServiceException(409, '{"detail":"version_mismatch"}')),
        TripsErrorKey.conflict,
      );
    });

    test('409 with trip_limit_reached body -> tripLimitReached', () {
      // The mobile UI gates its inline "Limit reached" branch on this exact
      // key. Renaming the backend detail string is a breaking contract
      // change — keep the substring stable.
      expect(
        mapTripsError(
            TripServiceException(409, '{"detail":"trip_limit_reached"}')),
        TripsErrorKey.tripLimitReached,
      );
    });

    test('500 -> generic', () {
      expect(
        mapTripsError(TripServiceException(500, 'boom')),
        TripsErrorKey.generic,
      );
    });

    test('non-service exception -> generic', () {
      expect(mapTripsError(StateError('whatever')), TripsErrorKey.generic);
    });
  });
}
