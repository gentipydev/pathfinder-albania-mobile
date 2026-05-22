import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Severity levels for [dlog]. Each level carries an emoji prefix for
/// quick visual scanning of the console and a short tag for grep.
enum LogLevel {
  debug('🔵', 'DEBUG', 500),
  info('🟢', 'INFO', 800),
  warning('🟡', 'WARN', 900),
  error('🔴', 'ERROR', 1000);

  final String emoji;
  final String tag;
  final int developerLevel;
  const LogLevel(this.emoji, this.tag, this.developerLevel);
}

/// Structured log that ALSO mirrors to [debugPrint] so it shows up in
/// `flutter run` stdout on iOS — `dart:developer.log` alone routes to
/// `os_log` and stays invisible there.
///
/// Format: `<emoji> <HH:mm:ss.SSS> <LEVEL> [name] message[ — error]`.
///
/// **Stripped from release builds** via the [kDebugMode] guard at the top —
/// every call site compiles away when `kReleaseMode` / `kProfileMode`.
///
/// - [name] tags the channel (e.g. `'buddy.stream'`, `'http'`, `'nav'`).
/// - [level] defaults to [LogLevel.debug] but is upgraded to
///   [LogLevel.error] automatically when [error] is supplied without an
///   explicit level — so `dlog('boom', error: e)` does the right thing.
void dlog(
  String message, {
  String? name,
  LogLevel? level,
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;
  final lvl = level ?? (error != null ? LogLevel.error : LogLevel.debug);
  final now = DateTime.now();
  final ts = _formatTimestamp(now);
  final tag = name != null ? '[$name] ' : '';
  final formatted = '${lvl.emoji} $ts ${lvl.tag} $tag$message';
  if (error != null) {
    debugPrint('$formatted — $error');
  } else {
    debugPrint(formatted);
  }
  developer.log(
    message,
    name: name ?? '',
    level: lvl.developerLevel,
    error: error,
    stackTrace: stackTrace,
    time: now,
  );
}

String _formatTimestamp(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  String three(int n) => n.toString().padLeft(3, '0');
  return '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}.${three(dt.millisecond)}';
}
