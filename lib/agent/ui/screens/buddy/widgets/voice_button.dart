import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/agent/features/voice/bloc/voice_bloc.dart';
import 'package:travel_buddy/agent/features/voice/bloc/voice_event.dart';
import 'package:travel_buddy/agent/features/voice/bloc/voice_state.dart';
import 'package:travel_buddy/logic/locale_logic.dart';

/// Tap-toggle mic button. Tap to start listening; tap again (or wait for the
/// recognizer's silence cutoff + auto-restart cycle) to stop. The screen
/// listens to `VoiceBloc.state.transcript` and streams the live text directly
/// into the composer's `TextField`.
class VoiceButton extends StatefulWidget {
  const VoiceButton({super.key});

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 1.08)
      .chain(CurveTween(curve: Curves.easeInOut))
      .animate(_pulse);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _syncPulse(bool isListening) {
    if (isListening && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!isListening && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0.0;
    }
  }

  void _handleTap(BuildContext context) {
    final bloc = context.read<VoiceBloc>();
    if (bloc.state.status == VoiceState.listening) {
      bloc.add(const VoiceStopRequested());
      return;
    }
    final lang = GetIt.I<LocaleLogic>().strings.localeName;
    bloc.add(VoiceStartRequested(localeId: _languageTag(lang)));
  }

  String _languageTag(String code) {
    switch (code) {
      case 'sq':
        return 'sq_AL';
      case 'en':
      default:
        return 'en_US';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return BlocSelector<VoiceBloc, VoiceBlocState, VoiceState>(
      selector: (s) => s.status,
      builder: (ctx, status) {
        final isListening = status == VoiceState.listening;
        _syncPulse(isListening);
        final bg = isListening ? colors.error : colors.accent1;
        final icon =
            isListening ? Icons.stop_rounded : Icons.mic_none_rounded;
        return Tooltip(
          message: isListening
              ? $strings.buddyVoiceStop
              : $strings.buddyVoiceTapToTalk,
          child: ScaleTransition(
            scale: _scale,
            child: Material(
              color: bg,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _handleTap(ctx),
                child: SizedBox(
                  height: 44,
                  width: 44,
                  child: Icon(icon, color: colors.black),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
