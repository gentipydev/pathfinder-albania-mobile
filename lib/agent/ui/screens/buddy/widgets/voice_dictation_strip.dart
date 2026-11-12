import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/agent/features/voice/bloc/voice_bloc.dart';
import 'package:pathfinder_albania/agent/features/voice/bloc/voice_state.dart';

/// A bare Siri-style waveform shown above the composer while voice dictation
/// is active. No background, no border, no buttons — the mic button on the
/// composer itself toggles listening, and the live transcript streams into
/// the composer's TextField directly. Slides in/out via `AnimatedSize`.
class VoiceDictationStrip extends StatelessWidget {
  const VoiceDictationStrip({super.key});

  @override
  Widget build(BuildContext context) {
    // Voice dictation is hidden on web — speech_to_text browser support is
    // unreliable, so the composer never enters a listening state there.
    if (kIsWeb) return const SizedBox.shrink();
    return BlocSelector<VoiceBloc, VoiceBlocState, VoiceState>(
      selector: (s) => s.status,
      builder: (ctx, status) {
        final visible = status == VoiceState.listening;
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomCenter,
          child: visible
              ? const _DictationBody()
              : const SizedBox(width: double.infinity),
        );
      },
    );
  }
}

class _DictationBody extends StatefulWidget {
  const _DictationBody();

  @override
  State<_DictationBody> createState() => _DictationBodyState();
}

class _DictationBodyState extends State<_DictationBody> {
  late final IOS9SiriWaveformController _wave;

  // Floor amplitude so the waveform keeps a subtle "breathing" motion even
  // during silence (siri_wave stops painting when amplitude == 0).
  static const double _silenceFloor = 0.10;

  @override
  void initState() {
    super.initState();
    final colors = $styles.colors;
    _wave = IOS9SiriWaveformController(
      amplitude: _silenceFloor,
      speed: 0.18,
      color1: colors.accent1,
      color2: colors.accent1.withValues(alpha: .75),
      color3: colors.offWhite.withValues(alpha: .55),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VoiceBloc, VoiceBlocState>(
      listenWhen: (a, b) => a.soundLevel != b.soundLevel,
      listener: (ctx, s) {
        _wave.amplitude = math.max(_silenceFloor, s.soundLevel);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: $styles.insets.lg,
          vertical: $styles.insets.xxs,
        ),
        child: SiriWaveform.ios9(
          controller: _wave,
          options: const IOS9SiriWaveformOptions(
            height: 88,
            width: double.infinity,
            showSupportBar: false,
          ),
        ),
      ),
    );
  }
}
