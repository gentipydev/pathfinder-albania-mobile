import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/agent/features/buddy/bloc/buddy_error_mapper.dart';

void main() {
  group('mapBuddyStreamError', () {
    test('null status code falls back to the upstream message', () {
      // No HTTP response (network-level failure). The chat_service
      // labels these with a useful prefix; we preserve them verbatim.
      expect(
        mapBuddyStreamError('Network error: SocketException', null),
        'Network error: SocketException',
      );
    });

    test('429 returns the rate-limited copy', () {
      final msg = mapBuddyStreamError('429', 429);
      expect(msg.toLowerCase(), contains('too fast'));
    });

    test('502 / 503 / 504 return the backend-down copy', () {
      for (final code in [502, 503, 504]) {
        final msg = mapBuddyStreamError('backend down', code);
        expect(
          msg.toLowerCase(),
          contains('temporarily unavailable'),
          reason: 'status code $code should be mapped',
        );
      }
    });

    test('generic 5xx returns the server-error copy', () {
      final msg = mapBuddyStreamError('something broke', 500);
      expect(msg.toLowerCase(), contains('something went wrong'));
    });

    test('non-mapped 4xx (e.g. 413) keeps the upstream message', () {
      // Caller-side mistakes — the upstream message is the more
      // useful signal (it includes the original detail).
      expect(
        mapBuddyStreamError('Payload too large', 413),
        'Payload too large',
      );
    });

    test('zero status code is treated as the no-response case', () {
      // Some failure paths in Dio yield statusCode=0 rather than null;
      // both should land on the same branch.
      expect(
        mapBuddyStreamError('connection reset', 0),
        'connection reset',
      );
    });
  });
}
