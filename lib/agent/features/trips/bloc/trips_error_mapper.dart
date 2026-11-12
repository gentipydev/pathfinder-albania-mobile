import 'package:pathfinder_albania/main.dart' show $strings;
import 'package:pathfinder_albania/agent/services/trip_service.dart';

/// Stable identifiers for user-facing trips errors. The Bloc emits one of
/// these via `TripsState.lastError`; the UI resolves to a localized string
/// via `$strings.<key>`. Decoupling the Bloc from BuildContext / l10n keeps
/// state pure-data and lets tests assert on a stable token.
class TripsErrorKey {
  const TripsErrorKey._();

  static const String signIn = 'tripsErrorSignIn';
  static const String notFound = 'tripsErrorNotFound';
  static const String conflict = 'tripsErrorConflict';
  static const String tripLimitReached = 'tripsErrorTripLimitReached';
  static const String generic = 'tripsErrorGeneric';
}

/// Translates a [TripService] failure into a [TripsErrorKey] constant.
/// Mirrors the historical mapping in `TripsLogic._setError`.
String mapTripsError(Object e) {
  if (e is TripServiceException) {
    switch (e.statusCode) {
      case 401:
        return TripsErrorKey.signIn;
      case 404:
        return TripsErrorKey.notFound;
      case 409:
        // Backend returns `{"detail":"trip_limit_reached"}` for the free-tier
        // cap. Substring is enough — avoids pulling dart:convert in here for
        // a single discriminator. Other 409s (e.g. optimistic-conflict on
        // reorder) fall through to the generic conflict key.
        if (e.body.contains('trip_limit_reached')) {
          return TripsErrorKey.tripLimitReached;
        }
        return TripsErrorKey.conflict;
    }
  }
  return TripsErrorKey.generic;
}

/// Resolves a [TripsErrorKey] constant (or a free-form pass-through string
/// from `TripsErrorSurfaced`) to a displayable user-facing message via the
/// gen-l10n `$strings` accessor. Fallbacks pass through unknown values so
/// `TripsErrorSurfaced("custom message")` still renders verbatim.
String resolveTripsErrorMessage(String? rawOrKey) {
  if (rawOrKey == null) return '';
  switch (rawOrKey) {
    case TripsErrorKey.signIn:
      return $strings.tripsErrorSignIn;
    case TripsErrorKey.notFound:
      return $strings.tripsErrorNotFound;
    case TripsErrorKey.conflict:
      return $strings.tripsErrorConflict;
    case TripsErrorKey.tripLimitReached:
      return $strings.tripsErrorTripLimitReached;
    case TripsErrorKey.generic:
      return $strings.tripsErrorGeneric;
    default:
      // Pass-through for legacy direct messages (e.g. TripsErrorSurfaced).
      return rawOrKey;
  }
}
