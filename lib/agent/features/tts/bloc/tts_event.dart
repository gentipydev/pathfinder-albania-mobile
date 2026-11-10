import 'package:equatable/equatable.dart';

abstract class TtsEvent extends Equatable {
  const TtsEvent();

  @override
  List<Object?> get props => const [];
}

/// Speak [text] for the given [messageId]. The handler stops any in-flight
/// playback first, so a second speak (different message) replaces the first.
class TtsSpeakRequested extends TtsEvent {
  const TtsSpeakRequested({
    required this.messageId,
    required this.text,
    this.localeId,
    this.fallbackLocales = const ['en-US'],
  });

  final String messageId;
  final String text;
  final String? localeId;
  final List<String> fallbackLocales;

  @override
  List<Object?> get props => [messageId, text, localeId, fallbackLocales];
}

class TtsStopRequested extends TtsEvent {
  const TtsStopRequested();
}

/// Internal: flutter_tts `setStartHandler` fired. Emitted from inside the
/// bloc after `_ensureInit` registers the platform callback.
class TtsStarted extends TtsEvent {
  const TtsStarted();
}

/// Internal: flutter_tts `setCompletionHandler` fired (utterance finished).
class TtsFinishedOk extends TtsEvent {
  const TtsFinishedOk();
}

/// Internal: flutter_tts `setCancelHandler` fired (engine cancelled —
/// typically because `_tts.stop()` was called). Distinguished from
/// `TtsStopRequested` so the cancel handler can run unconditionally; the
/// stop event itself is the user-driven entry point.
class TtsCancelledByEngine extends TtsEvent {
  const TtsCancelledByEngine();
}

/// Internal: flutter_tts `setErrorHandler` fired. Resets state to idle.
class TtsErroredByEngine extends TtsEvent {
  const TtsErroredByEngine();
}
