import 'package:sentry_flutter/sentry_flutter.dart';

/// Mobile-side mirror of the backend's `_scrub_pii` (see
/// `travel-buddy-backend/app/observability/sentry.py`). Strips user-generated
/// content from Sentry events before they leave the device.
///
/// Returns the (mutated) event so it can be used as `options.beforeSend`. To
/// drop an event entirely, return null — currently we never do because losing
/// the error stack would defeat the purpose; we'd rather redact than drop.
const _redacted = '[redacted]';

// Allow-list of JSON keys whose values may carry user-authored text. The
// scrubber recursively walks Sentry event payloads (request bodies,
// breadcrumb data) and redacts any value reached through one of these
// keys. Mirror of backend `_PII_REQUEST_KEYS`
// (`travel-buddy-backend/app/observability/sentry.py`); the two lists
// drift independently when an endpoint adds a new free-text field, so
// audit checklist when adding a new endpoint:
//
//   1. Does the request body have a free-text field (message, notes,
//      title, summary, persona, anything user-typed)? → Add the key.
//   2. Does the response body echo a free-text field that might land
//      in a Sentry breadcrumb? → Add the key.
//   3. Are field names camelCase or snake_case across mobile/backend?
//      The scrubber checks both; list both spellings if unsure.
//
// Current coverage (last audited 2026-05-21):
//   chat.stream — message, content, messages
//   /preferences — persona, persona_text, personaText, personality, summary
//   /trips — title, name, base_city, baseCity, notes, summary
//   /chat/stream refine — trip_json (refine_addendum's payload), reason
//                         (refine_failed / itinerary_invalid bodies)
//   conversation history — assistant_text (legacy field name; current
//                          path uses 'content' but covered for safety)
const _piiKeys = <String>{
  'message',
  'messages',
  'content',
  'persona',
  'personaText',
  'persona_text',
  'personality',
  'summary',
  'title',
  'name',
  'baseCity',
  'base_city',
  'notes',
  // Added 2026-05-21 robustness pass — bodies carrying refine state and
  // server-emitted rejection reasons.
  'trip_json',
  'trip',
  'refine_addendum',
  'assistant_text',
  'reason',
};

SentryEvent? scrubSentryEvent(SentryEvent event) {
  try {
    // 1. Request body — `event.request?.data` may be a Map or a String.
    final req = event.request;
    if (req != null) {
      final data = req.data;
      if (data is Map) {
        event = event.copyWith(
          request: req.copyWith(data: _scrubMap(Map<String, dynamic>.from(data))),
        );
      } else if (data is String) {
        event = event.copyWith(
          request: req.copyWith(data: _redacted),
        );
      }
    }

    // 2. User email — id + uid are non-PII per our privacy model.
    final user = event.user;
    if (user != null && user.email != null) {
      event = event.copyWith(user: user.copyWith(email: _redacted));
    }

    // 3. Breadcrumb data — often captures request payload echoes.
    final crumbs = event.breadcrumbs;
    if (crumbs != null && crumbs.isNotEmpty) {
      final scrubbed = crumbs
          .map((c) => c.data == null
              ? c
              : c.copyWith(data: _scrubMap(Map<String, dynamic>.from(c.data!))))
          .toList();
      event = event.copyWith(breadcrumbs: scrubbed);
    }
  } catch (_) {
    // Never raise — losing the error event would defeat Sentry's purpose.
    // The scrubber's failure mode is "send the event un-scrubbed," which is
    // bad but not as bad as silently dropping prod errors.
  }
  return event;
}

dynamic _scrubValue(dynamic value) {
  if (value is Map) {
    return value.map((k, v) => MapEntry(k, _scrubValue(v)));
  }
  if (value is List) {
    return value.map(_scrubValue).toList();
  }
  if (value is String) {
    return _redacted;
  }
  return value;
}

Map<String, dynamic> _scrubMap(Map<String, dynamic> data) {
  final out = <String, dynamic>{};
  data.forEach((k, v) {
    if (_piiKeys.contains(k)) {
      out[k] = _scrubValue(v);
    } else if (v is Map) {
      out[k] = _scrubMap(Map<String, dynamic>.from(v));
    } else if (v is List) {
      out[k] = v
          .map((item) => item is Map
              ? _scrubMap(Map<String, dynamic>.from(item))
              : item)
          .toList();
    } else {
      out[k] = v;
    }
  });
  return out;
}
