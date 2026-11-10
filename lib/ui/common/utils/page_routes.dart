import 'package:flutter/cupertino.dart';

class PageRoutes {
  static const Duration kDefaultDuration = Duration(milliseconds: 300);

  /// A transparent, fading fullscreen dialog route.
  static Route<T> dialog<T>(
    Widget child, {
    Duration duration = kDefaultDuration,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      opaque: false,
      fullscreenDialog: true,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
