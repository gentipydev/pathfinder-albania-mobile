import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pathfinder_albania/utils/sentry_scrubber.dart';

void main() {
  group('scrubSentryEvent — robustness audit (2026-05-21)', () {
    // These tests pin the keys added in the audit. If a future refactor
    // removes one of them from _piiKeys, the assertion fails — surfacing
    // the regression before it ships PII to Sentry.

    test('redacts trip_json in request body', () {
      final event = SentryEvent(
        request: SentryRequest(
          data: {'trip_json': 'A user-described trip stored verbatim.'},
        ),
      );
      final out = scrubSentryEvent(event);
      expect((out?.request?.data as Map?)?['trip_json'], '[redacted]');
    });

    test('redacts refine_addendum + assistant_text + reason', () {
      final event = SentryEvent(
        request: SentryRequest(
          data: {
            'refine_addendum': 'CALL update_stop with stop_id=…',
            'assistant_text': 'Done — I shortened the museum stop to 45 minutes.',
            'reason': 'days: Field required',
          },
        ),
      );
      final data = scrubSentryEvent(event)?.request?.data as Map?;
      expect(data?['refine_addendum'], '[redacted]');
      expect(data?['assistant_text'], '[redacted]');
      expect(data?['reason'], '[redacted]');
    });

    test('keeps non-PII structural keys intact', () {
      // statusCode, id, version, hash, durationMs — none of these
      // carry user content; scrubbing them would degrade debug data.
      final event = SentryEvent(
        request: SentryRequest(
          data: {
            'statusCode': 429,
            'request_id': 'abc-123',
            'durationMs': 432,
          },
        ),
      );
      final data = scrubSentryEvent(event)?.request?.data as Map?;
      expect(data?['statusCode'], 429);
      expect(data?['request_id'], 'abc-123');
      expect(data?['durationMs'], 432);
    });
  });

  group('scrubSentryEvent', () {
    test('redacts chat message in request.data', () {
      final event = SentryEvent(
        request: SentryRequest(
          data: {'message': 'What should I do in Berat?'},
        ),
      );
      final out = scrubSentryEvent(event);
      final data = out?.request?.data as Map?;
      expect(data?['message'], '[redacted]');
    });

    test('redacts user email but keeps id', () {
      final event = SentryEvent(
        user: SentryUser(id: 'uid-123', email: 'alice@example.com'),
      );
      final out = scrubSentryEvent(event);
      expect(out?.user?.email, '[redacted]');
      expect(out?.user?.id, 'uid-123');
    });

    test('recursively redacts nested persona payload', () {
      final event = SentryEvent(
        request: SentryRequest(
          data: {
            'persona': {
              'tone': 'friendly',
              'personality': 'loves history and food',
            }
          },
        ),
      );
      final out = scrubSentryEvent(event);
      final persona = (out?.request?.data as Map)['persona'] as Map;
      expect(persona['tone'], '[redacted]');
      expect(persona['personality'], '[redacted]');
    });

    test('redacts every string leaf inside messages list', () {
      final event = SentryEvent(
        request: SentryRequest(
          data: {
            'messages': [
              {'role': 'user', 'content': 'Add Castle of Berat'},
              {'role': 'assistant', 'content': 'Added.'},
            ],
          },
        ),
      );
      final out = scrubSentryEvent(event);
      final messages = (out?.request?.data as Map)['messages'] as List;
      for (final m in messages.cast<Map>()) {
        // `messages` is a PII key — every leaf is scrubbed, including role.
        // Same tradeoff as the backend scrubber: safer to lose role than to
        // ever leak content.
        expect(m['role'], '[redacted]');
        expect(m['content'], '[redacted]');
      }
    });

    test('passes through unrelated fields', () {
      final event = SentryEvent(
        request: SentryRequest(
          data: {
            'trip_id': 'abc',
            'limit': 20,
            'cursor': '2026-05-18T00:00:00|abc',
          },
        ),
      );
      final out = scrubSentryEvent(event);
      final data = out?.request?.data as Map;
      expect(data['trip_id'], 'abc');
      expect(data['limit'], 20);
      expect(data['cursor'], '2026-05-18T00:00:00|abc');
    });

    test('redacts raw-string body wholesale', () {
      final event = SentryEvent(
        request: SentryRequest(data: '{"message":"hi"}'),
      );
      final out = scrubSentryEvent(event);
      expect(out?.request?.data, '[redacted]');
    });

    test('never throws on malformed event', () {
      // Pathological shapes still return a valid event rather than blowing
      // up — losing the error would defeat Sentry's purpose.
      final event = SentryEvent();
      final out = scrubSentryEvent(event);
      expect(out, isNotNull);
    });
  });
}
