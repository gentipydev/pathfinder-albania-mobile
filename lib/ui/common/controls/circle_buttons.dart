import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/ui/common/app_icons.dart';
import 'package:pathfinder_albania/ui/common/fullscreen_keyboard_listener.dart';

class CircleBtn extends StatelessWidget {
  const CircleBtn({
    super.key,
    required this.child,
    required this.onPressed,
    this.bgColor,
    required this.semanticLabel,
  });

  static double defaultSize = 48;

  final VoidCallback? onPressed;
  final Color? bgColor;
  final Widget child;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    double sz = defaultSize;
    return AppBtn(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      minimumSize: Size(sz, sz),
      padding: EdgeInsets.zero,
      circular: true,
      bgColor: bgColor,
      child: child,
    );
  }
}

class CircleIconBtn extends StatelessWidget {
  const CircleIconBtn({
    super.key,
    required this.icon,
    required this.onPressed,
    this.bgColor,
    this.flipIcon = false,
    required this.semanticLabel,
  });

  //TODO: Reduce size if design re-exports icon-images without padding
  static double defaultSize = 28;

  final AppIcons icon;
  final VoidCallback? onPressed;
  final Color? bgColor;
  final String semanticLabel;
  final bool flipIcon;

  @override
  Widget build(BuildContext context) {
    Color defaultColor = $styles.colors.greyStrong;
    return CircleBtn(
      onPressed: onPressed,
      bgColor: bgColor ?? defaultColor,
      semanticLabel: semanticLabel,
      child: Transform.scale(
        scaleX: flipIcon ? -1 : 1,
        child: AppIcon(icon, size: defaultSize, color: $styles.colors.offWhite),
      ),
    );
  }
}

class BackBtn extends StatelessWidget {
  const BackBtn({
    super.key,
    this.icon = AppIcons.prev,
    this.onPressed,
    this.semanticLabel,
  });

  final AppIcons icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  bool _handleKeyDown(BuildContext context, KeyDownEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _handleOnPressed(context);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FullscreenKeyboardListener(
      onKeyDown: (event) => _handleKeyDown(context, event),
      child: CircleIconBtn(
        icon: icon,
        onPressed:
            onPressed ??
            () {
              final nav = Navigator.of(context);
              if (nav.canPop()) {
                Navigator.pop(context);
              } else {
                context.go(ScreenPaths.home);
              }
            },
        semanticLabel: semanticLabel ?? $strings.circleButtonsSemanticBack,
      ),
    );
  }

  void _handleOnPressed(BuildContext context) {
    if (onPressed != null) {
      onPressed?.call();
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(ScreenPaths.home);
      }
    }
  }
}
