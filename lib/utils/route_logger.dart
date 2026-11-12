import 'package:flutter/widgets.dart';
import 'package:pathfinder_albania/utils/dlog.dart';

const String _channel = 'nav';

/// `NavigatorObserver` that logs every push, pop, remove and replace under
/// the `nav` channel. Wired into `appRouter` behind `kDebugMode` so it has
/// zero release-build cost (and `dlog` itself is also `kDebugMode` gated).
///
/// The route name shown is `Route.settings.name` when `GoRouter` populates
/// it; otherwise it falls back to `RouteSettings.toString()`.
class LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    dlog(
      'push ${_describe(route)} (from ${_describe(previousRoute)})',
      name: _channel,
      level: LogLevel.info,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    dlog(
      'pop ${_describe(route)} → back to ${_describe(previousRoute)}',
      name: _channel,
      level: LogLevel.info,
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    dlog(
      'remove ${_describe(route)}',
      name: _channel,
      level: LogLevel.info,
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    dlog(
      'replace ${_describe(oldRoute)} → ${_describe(newRoute)}',
      name: _channel,
      level: LogLevel.info,
    );
  }

  String _describe(Route<dynamic>? r) {
    if (r == null) return 'none';
    final name = r.settings.name;
    if (name != null && name.isNotEmpty) return name;
    return r.settings.toString();
  }
}
