import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_buddy/utils/dlog.dart';

const String _channel = 'bloc';

/// Debug-only observer that logs the full bloc lifecycle: create, every
/// inbound event, every state transition (with a prop-index diff for
/// Equatable states), errors, and close.
///
/// Wired in `main.dart` behind `kDebugMode`. The motivation is the Phase 3
/// risk that an in-place mutation of immutable state (or a forgotten
/// `copyWith`) silently no-ops because Bloc relies on `Equatable` prop
/// equality — without an observer, the symptom would be "UI doesn't update"
/// with no exception. With this observer, every transition lands in stdout
/// during a debug run, making no-op emits and accidental drops obvious.
///
/// All emissions go through [dlog] so they share the app's emoji+timestamp
/// format and are stripped from release builds by the same `kDebugMode`
/// gate that owns `dlog`.
class DevBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    dlog('${bloc.runtimeType} created', name: _channel, level: LogLevel.info);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    dlog('${bloc.runtimeType} ← ${event.runtimeType}', name: _channel);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    final diff = _diffStates(change.currentState, change.nextState);
    dlog(
      '${bloc.runtimeType}: ${change.currentState.runtimeType} → ${change.nextState.runtimeType}$diff',
      name: _channel,
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    dlog(
      '${bloc.runtimeType} ${transition.event.runtimeType} ⇒ ${transition.nextState.runtimeType}',
      name: _channel,
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    dlog(
      '${bloc.runtimeType} error',
      name: _channel,
      level: LogLevel.error,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    dlog('${bloc.runtimeType} closed', name: _channel, level: LogLevel.info);
  }

  /// Returns ` (changed: #i: prev→next, ...)` for the Equatable props that
  /// differ between two states, or `''` when either side isn't Equatable.
  /// Prop names aren't available without reflection, so indices are the
  /// best we can offer; readers can grep the bloc's `props` getter.
  String _diffStates(Object? prev, Object? next) {
    if (prev is! Equatable || next is! Equatable) return '';
    final p = prev.props;
    final n = next.props;
    if (p.length != n.length) {
      return ' (props.length: ${p.length}→${n.length})';
    }
    final changed = <String>[];
    for (var i = 0; i < p.length; i++) {
      if (p[i] != n[i]) {
        changed.add('#$i: ${_short(p[i])}→${_short(n[i])}');
      }
    }
    return changed.isEmpty ? '' : ' (changed: ${changed.join(", ")})';
  }

  String _short(Object? v) {
    if (v == null) return 'null';
    final s = v.toString();
    return s.length > 60 ? '${s.substring(0, 57)}…' : s;
  }
}
