import 'package:geolocator/geolocator.dart';

/// Outcome of [LocationService.requestForUse]. Collapses the
/// `(isServiceEnabled, LocationPermission)` pair into the four states the
/// UI actually has to surface — granted, denied (re-promptable),
/// deniedForever (Settings only), or serviceDisabled (device-wide off).
enum LocationEnableStatus { granted, denied, deniedForever, serviceDisabled }

/// Thin wrapper around `geolocator`. Centralizes permission checks and the
/// position stream so the rest of the app (VisitDetectorBloc, the consent
/// sheet, the AppBar overflow toggle) doesn't import geolocator directly —
/// makes swapping or stubbing the source trivial.
///
/// Foreground-only by design (per privacy.md). Background geofencing would
/// require ACCESS_BACKGROUND_LOCATION + NSLocationAlwaysUsageDescription
/// and a separate evaluation; intentionally out of scope.
class LocationService {
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  /// Triggers the system permission prompt if status is `denied`. On
  /// `deniedForever` the user must open Settings — we return the same
  /// status and let the caller surface that.
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  /// Combined "can we actually use location right now?" check. Used by the
  /// auto-track toggle so the UI can branch on a single status enum instead
  /// of juggling the service flag and the permission enum separately.
  /// The system permission prompt is only shown for the `denied` →
  /// `granted` transition; `deniedForever` and `serviceDisabled` cases
  /// return without prompting (the caller routes the user to Settings).
  Future<LocationEnableStatus> requestForUse() async {
    final enabled = await isServiceEnabled();
    if (!enabled) return LocationEnableStatus.serviceDisabled;
    final perm = await requestPermission();
    return switch (perm) {
      LocationPermission.whileInUse ||
      LocationPermission.always =>
        LocationEnableStatus.granted,
      LocationPermission.deniedForever => LocationEnableStatus.deniedForever,
      _ => LocationEnableStatus.denied,
    };
  }

  /// Opens the OS app-permission page for Pathfinder Albania (used when location
  /// access is `deniedForever`).
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Opens the device-wide Location Services settings (used when Location
  /// Services are off entirely).
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Single-shot position. Returns `null` when the platform refuses
  /// (location off, permission denied, etc.) so the caller can decide
  /// whether to surface an error or just bail.
  Future<Position?> getCurrent() async {
    final enabled = await isServiceEnabled();
    if (!enabled) return null;
    final perm = await checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Continuous position stream. Only emits when the device moves more
  /// than [distanceFilterMeters] (default 25 m) so we don't spam updates
  /// while the user is stationary at a stop.
  Stream<Position> positions({int distanceFilterMeters = 25}) =>
      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilterMeters,
        ),
      );
}
