import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_bloc.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_error_mapper.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_event.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_state.dart';

/// Inline transient banner mounted at the top of the trip-detail screen and
/// the My Trips list. Watches `TripsBloc.state.lastError`; slides in when the
/// value goes from null to non-null, auto-dismisses after [autoDismiss], or
/// dismisses immediately on tap. The codebase prefers this over SnackBars.
class TripErrorBanner extends StatefulWidget {
  const TripErrorBanner({super.key, this.autoDismiss = const Duration(seconds: 3)});

  final Duration autoDismiss;

  @override
  State<TripErrorBanner> createState() => _TripErrorBannerState();
}

class _TripErrorBannerState extends State<TripErrorBanner>
    with SingleTickerProviderStateMixin {
  Timer? _autoDismissTimer;
  String? _displayed;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    final initial = context.read<TripsBloc>().state.lastError;
    if (initial != null) {
      _displayed = initial;
      _controller.value = 1;
      _scheduleAutoDismiss();
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleAutoDismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(widget.autoDismiss, () {
      if (!mounted) return;
      final bloc = context.read<TripsBloc>();
      if (bloc.state.lastError != null) {
        bloc.add(const ErrorDismissed());
      }
    });
  }

  void _onErrorChanged(String? err) {
    _autoDismissTimer?.cancel();
    if (err != null) {
      setState(() => _displayed = err);
      _controller.forward();
      _scheduleAutoDismiss();
    } else {
      _controller.reverse();
    }
  }

  void _dismiss() {
    context.read<TripsBloc>().add(const ErrorDismissed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripsBloc, TripsState>(
      listenWhen: (a, b) => a.lastError != b.lastError,
      listener: (context, state) => _onErrorChanged(state.lastError),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final txt = _displayed;
          if (txt == null && _controller.status == AnimationStatus.dismissed) {
            return const SizedBox.shrink();
          }
          return SlideTransition(
            position: _slide,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismiss,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: $styles.colors.greyStrong,
                  border: Border(
                    left: BorderSide(color: $styles.colors.error, width: 3),
                    bottom: BorderSide(
                      color: Colors.black.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: $styles.insets.md,
                  vertical: $styles.insets.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: $styles.colors.error,
                      size: 18,
                    ),
                    Gap($styles.insets.sm),
                    Expanded(
                      child: Text(
                        resolveTripsErrorMessage(txt),
                        style: $styles.text.body.copyWith(
                          color: $styles.colors.offWhite,
                        ),
                      ),
                    ),
                    Gap($styles.insets.sm),
                    Icon(
                      Icons.close,
                      color: $styles.colors.offWhite.withValues(alpha: 0.6),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
