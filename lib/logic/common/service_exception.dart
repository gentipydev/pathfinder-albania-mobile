/// Common supertype for the service-layer exceptions
/// ([TripServiceException], [UserServiceException], [HttpException], …).
///
/// Blocs can `catch` a single type and branch on [statusCode] instead of
/// catching each concrete class separately. Declared with a `statusCode`
/// getter (not a constructor) so existing classes opt in by changing
/// `implements Exception` → `implements ServiceException` — their existing
/// `final int statusCode` field already satisfies the contract, no
/// constructor churn required.
abstract class ServiceException implements Exception {
  /// HTTP status code that produced this error, or a sentinel (e.g. -1)
  /// when the failure was a transport error with no response.
  int get statusCode;
}
