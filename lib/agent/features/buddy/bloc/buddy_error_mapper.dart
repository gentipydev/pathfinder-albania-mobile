/// Translate a `StreamError.statusCode` into the user-facing string we set
/// on `state.lastError`. Mirrors the role of `trips_error_mapper.dart`.
///
/// Status-code-aware mapping: a bare "Network error" is fine when the
/// server is unreachable, but a 429 ("slow down") and a 503 ("service
/// temporarily down") read differently to a user. Defaulting to the
/// upstream `StreamError.message` preserves the original behaviour for
/// uncategorized errors — including auth and the long-tail of weird
/// network states the chat_service already labels usefully.
///
/// Strings are English-literal today; the matching ARB keys live in
/// `lib/l10n/app_en.arb` (`chatErrorRateLimited`, `chatErrorBackendDown`,
/// `chatErrorServerError`, `chatErrorNetwork`). The mapper takes plain
/// strings so call sites don't need a BuildContext just to produce a
/// `lastError` — the localized values are passed in by the caller (the
/// Bloc resolves them once via `$strings.chat...` and forwards).
String mapBuddyStreamError(String message, int? statusCode) {
  if (statusCode == null || statusCode == 0) {
    // Network-level failure (no HTTP response). Examples: DNS, socket
    // reset, timeout. The upstream message often already reads "Network
    // error: …" — surface it verbatim so debug data isn't lost.
    return message;
  }
  if (statusCode == 429) {
    // Rate limited. Backend includes a `Retry-After` header which a
    // higher-level RateLimitedEvent already surfaces with a countdown;
    // this string is the fallback shown when the event handler hasn't
    // fired yet (e.g., the stream errors mid-frame).
    return 'You\'re sending messages too fast — please wait a moment and try again.';
  }
  if (statusCode == 502 || statusCode == 503 || statusCode == 504) {
    // Backend reachable through a proxy that itself is unhealthy
    // (a deploy rolling out, or a cold-start past the 90s receive
    // timeout). Recoverable; the next send usually works.
    return 'Pathfinder is temporarily unavailable. Try again in a moment.';
  }
  if (statusCode >= 500) {
    // Catch-all server error. Distinct from 502/503 to allow analytics
    // to slice them later; the user-facing string is intentionally the
    // same family of copy (recoverable, not user-fault).
    return 'Something went wrong on our side. Try sending the message again.';
  }
  // 4xx (non-429) — caller-side mistake (e.g., 413 payload too large).
  // Keep the upstream message; the chat_service tends to label these.
  return message;
}
