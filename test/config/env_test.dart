import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/config/env.dart';

void main() {
  group('Env.parseAppMode', () {
    test('missing or empty means full (keeps builds without APP_MODE unchanged)', () {
      expect(Env.parseAppMode(null), AppMode.full);
      expect(Env.parseAppMode(''), AppMode.full);
      expect(Env.parseAppMode('   '), AppMode.full);
    });

    test('accepts showcase and full, ignoring case and spaces', () {
      expect(Env.parseAppMode('showcase'), AppMode.showcase);
      expect(Env.parseAppMode(' Showcase '), AppMode.showcase);
      expect(Env.parseAppMode('full'), AppMode.full);
      expect(Env.parseAppMode('FULL'), AppMode.full);
    });

    test('rejects anything else instead of silently picking a mode', () {
      expect(() => Env.parseAppMode('showcse'), throwsStateError);
      expect(() => Env.parseAppMode('true'), throwsStateError);
    });
  });

  group('Env.resolveApiBaseUrl', () {
    test('uses API_BASE_URL when set', () {
      expect(Env.resolveApiBaseUrl('https://api.test', isDebug: false), 'https://api.test');
      expect(Env.resolveApiBaseUrl(' https://api.test ', isDebug: true), 'https://api.test');
    });

    test('debug builds fall back to the local dev backend', () {
      expect(Env.resolveApiBaseUrl(null, isDebug: true), 'http://127.0.0.1:8000');
    });

    test('release builds without it get an empty URL instead of crashing or a dev host', () {
      expect(Env.resolveApiBaseUrl(null, isDebug: false), '');
      expect(Env.resolveApiBaseUrl('', isDebug: false), '');
    });
  });

  group('Env.assertValid', () {
    test('showcase mode needs no Supabase keys', () {
      dotenv.loadFromString(envString: 'APP_MODE=showcase');
      expect(Env.agentEnabled, isFalse);
      expect(Env.assertValid, returnsNormally);
    });

    test('full mode requires the Supabase keys', () {
      dotenv.loadFromString(envString: 'APP_MODE=full');
      expect(Env.agentEnabled, isTrue);
      expect(Env.assertValid, throwsStateError);
    });

    test('full mode with Supabase keys passes', () {
      dotenv.loadFromString(
        envString: 'APP_MODE=full\nSUPABASE_URL=https://x.supabase.co\nSUPABASE_ANON_KEY=anon',
      );
      expect(Env.assertValid, returnsNormally);
    });

    test('an invalid APP_MODE fails at startup', () {
      dotenv.loadFromString(
        envString: 'APP_MODE=demo\nSUPABASE_URL=https://x.supabase.co\nSUPABASE_ANON_KEY=anon',
      );
      expect(Env.assertValid, throwsStateError);
    });
  });
}
