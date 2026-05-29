import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_event.dart';
import 'package:travel_buddy/features/settings/bloc/settings_bloc.dart';
import 'package:travel_buddy/features/settings/bloc/settings_state.dart';
import 'package:travel_buddy/logic/common/animate_utils.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';
import 'package:travel_buddy/ui/common/app_icons.dart';
import 'package:travel_buddy/ui/common/controls/app_header.dart';
import 'package:travel_buddy/ui/common/controls/locale_switcher.dart';
import 'package:travel_buddy/ui/common/pop_navigator_underlay.dart';
import 'package:travel_buddy/ui/common/utils/duration_utils.dart';
import 'package:travel_buddy/ui/common/travel_buddy_logo.dart';
import 'package:travel_buddy/ui/screens/home_menu/about_dialog_content.dart';

/// Context-aware Travel Buddy hub. Opened from the top-left button on the
/// Explore tab, it receives the destination currently in view (`widget.data`)
/// and turns it into action — leading with "Plan a trip to {destination}" and
/// "Ask Buddy about {destination}", which switch to the Buddy tab and stream a
/// response. A compact quick-jump row still lets the user move the Explore
/// carousel to any destination (popping the picked [DestinationType], same as
/// before). Bottom rows reach the cross-app surfaces: conversations history,
/// travel preferences, and About.
class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key, required this.data});
  final DestinationData data;

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  /// Destination the hero card + CTAs currently target. Seeded from the
  /// destination in view when the menu opened; tapping a tile in the jump row
  /// re-targets it in place (the menu stays open and the showcase carousel is
  /// not moved).
  late DestinationData _selected = widget.data;

  void _handleAboutPressed(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showAboutDialog(
      context: context,
      applicationName: $strings.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese: '© 2026 Travel Buddy',
      children: [AboutDialogContent()],
      applicationIcon: Container(
        color: $styles.colors.black,
        padding: EdgeInsets.all($styles.insets.xs),
        child: TravelBuddyLogo(width: 52),
      ),
    );
  }

  /// Switch to the Buddy tab and ask it to plan a trip to the destination in
  /// view. Reuses the same `BuddySendMessageRequested` path as the welcome
  /// suggestion chips and the `BuddyTabRequested` switch used by "Refine with
  /// Buddy". `BuddyRefineModeExited` first guards against an active refine
  /// session silently turning this into a trip-edit instead of a fresh plan.
  void _handlePlanTrip(BuildContext context) {
    final buddy = context.read<BuddyBloc>();
    buddy.add(const BuddyRefineModeExited());
    buddy.add(const BuddyTabRequested(1));
    buddy.add(BuddySendMessageRequested(
      text: $strings.homeMenuPlanTripPrompt(_selected.title),
    ));
    Navigator.pop(context);
  }

  /// Switch to the Buddy tab and ask an informational question about the
  /// destination in view. Same wiring as [_handlePlanTrip].
  void _handleAskBuddy(BuildContext context) {
    final buddy = context.read<BuddyBloc>();
    buddy.add(const BuddyRefineModeExited());
    buddy.add(const BuddyTabRequested(1));
    buddy.add(BuddySendMessageRequested(
      text: $strings.homeMenuAskBuddyPrompt(_selected.title),
    ));
    Navigator.pop(context);
  }

  void _handleConversationsPressed(BuildContext context) =>
      context.go(ScreenPaths.conversations);

  void _handlePreferencesPressed(BuildContext context) =>
      context.go(ScreenPaths.preferences);

  @override
  Widget build(BuildContext context) {
    final double contentWidth =
        (context.sizePx.shortestSide * 0.92).clamp(300.0, 440.0);
    return Stack(
      children: [
        /// Background — the app's solid dark surface.
        Positioned.fill(
          child: ColoredBox(color: $styles.colors.black),
        ),

        PopNavigatorUnderlay(),

        /// Content
        SafeArea(
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: ExpandedScrollingColumn(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Gap(50),
                  Gap($styles.insets.md),
                  _buildHero(context)
                      .maybeAnimate()
                      .fade(duration: $styles.times.fast)
                      .scale(begin: Offset(.9, .9), curve: Curves.easeOut),
                  Gap($styles.insets.lg),
                  _buildJumpRow(context),
                  Gap($styles.insets.lg),
                  _buildBottomBtns(context),
                  Gap($styles.insets.md),
                ],
              ),
            ),
          ),
        ),

        AppHeader(
          isTransparent: true,
          backIcon: AppIcons.close,
          trailing: (_) => LocaleSwitcher(),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    final colors = $styles.colors;
    final data = _selected;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          $strings.homeMenuViewingLabel.toUpperCase(),
          style: $styles.text.bodySmallBold.copyWith(
            color: colors.greyMedium,
            letterSpacing: 1.5,
          ),
        ),
        Gap($styles.insets.sm),
        Container(
          padding: EdgeInsets.all($styles.insets.md),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular($styles.corners.md),
            border: Border.all(color: colors.offWhite.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular($styles.corners.md),
                    child: Container(
                      width: 76,
                      height: 76,
                      color: data.type.fgColor,
                      child: Image.asset(data.type.homeBtn, fit: BoxFit.cover),
                    ),
                  ),
                  Gap($styles.insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.title,
                          style: $styles.text.contentFont.copyWith(
                            color: colors.offWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (data.subTitle.isNotEmpty) ...[
                          Gap($styles.insets.xs),
                          Text(
                            data.subTitle,
                            style: $styles.text.bodySmall.copyWith(
                              color: colors.greyMedium,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Gap($styles.insets.md),
              Row(
                children: [
                  Expanded(
                    child: _CtaBtn(
                      label: $strings.homeMenuPlanTrip,
                      icon: Icons.auto_awesome_rounded,
                      primary: true,
                      onPressed: () => _handlePlanTrip(context),
                    ),
                  ),
                  Gap($styles.insets.sm),
                  Expanded(
                    child: _CtaBtn(
                      label: $strings.homeMenuAskBuddy,
                      icon: Icons.chat_bubble_outline_rounded,
                      primary: false,
                      onPressed: () => _handleAskBuddy(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJumpRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          $strings.homeMenuJumpToDestination.toUpperCase(),
          style: $styles.text.bodySmallBold.copyWith(
            color: $styles.colors.greyMedium,
            letterSpacing: 1.5,
          ),
        ),
        Gap($styles.insets.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SeparatedRow(
            separatorBuilder: () => Gap($styles.insets.sm),
            children: [
              for (final d in destinationsLogic.all)
                _GridBtn(
                  d,
                  _selected,
                  onPressed: () => setState(() => _selected = d),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBtns(BuildContext context) {
    return BlocSelector<SettingsBloc, SettingsState, String?>(
      selector: (s) => s.currentLocale,
      builder: (_, _) {
        return SeparatedColumn(
          separatorBuilder: () => Divider(thickness: 1.5, height: 1).maybeAnimate().scale(
            duration: $styles.times.slow,
            delay: $styles.times.pageTransition + 200.delayMs,
            curve: Curves.easeOutBack,
          ),
          children:
              [
                    _MenuTextBtn(
                      label: $strings.homeMenuConversations,
                      icon: Icons.forum_outlined,
                      onPressed: () => _handleConversationsPressed(context),
                    ),
                    _MenuTextBtn(
                      label: $strings.homeMenuPreferences,
                      icon: Icons.tune_rounded,
                      onPressed: () => _handlePreferencesPressed(context),
                    ),
                    _MenuTextBtn(
                      label: $strings.homeMenuButtonAbout,
                      icon: Icons.info_outline_rounded,
                      onPressed: () => _handleAboutPressed(context),
                    ),
                  ]
                  .animate(interval: 50.delayMs)
                  .fade(delay: $styles.times.pageTransition + 50.delayMs)
                  .slide(begin: Offset(0, .1), curve: Curves.easeOut),
        );
      },
    );
  }
}

/// Filled (primary) or outlined (secondary) call-to-action used on the hero
/// card. Filled uses accent1 on black text; outlined uses an accent1 hairline
/// with accent1 text.
class _CtaBtn extends StatelessWidget {
  const _CtaBtn({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.primary,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final fg = primary ? colors.black : colors.accent1;
    return AppBtn(
      expand: true,
      padding: EdgeInsets.symmetric(vertical: $styles.insets.sm + 2),
      onPressed: onPressed,
      bgColor: primary ? colors.accent1 : Colors.transparent,
      border: primary
          ? null
          : BorderSide(color: colors.accent1.withValues(alpha: .6), width: 1),
      semanticLabel: label,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: fg, size: 18),
          Gap($styles.insets.xs),
          Flexible(
            child: Text(
              label,
              style: $styles.text.bodyBold.copyWith(color: fg, height: 1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridBtn extends StatefulWidget {
  const _GridBtn(this.btnData, this.selectedData, {required this.onPressed});
  final DestinationData btnData;
  final DestinationData selectedData;
  final VoidCallback onPressed;
  double _btnSize(BuildContext context) => (context.sizePx.shortestSide / 5).clamp(60, 100);

  @override
  State<_GridBtn> createState() => _GridBtnState();
}

class _GridBtnState extends State<_GridBtn> {
  bool _isOver = false;

  @override
  Widget build(BuildContext context) {
    final btnData = widget.btnData;
    final isSelected = btnData == widget.selectedData;
    final size = widget._btnSize(context);
    final accent = $styles.colors.accent1;

    Widget iconImage = Image.asset(btnData.type.homeBtn, fit: BoxFit.cover);

    // Selection is shown by an accent-orange ring drawn *around* the tile plus
    // dimming the unselected tiles — consistent on both light and dark icon
    // backgrounds (an inner off-white border vanished on the pale tiles). The
    // transparent ring on unselected tiles keeps every tile the same size, so
    // nothing shifts when the selection moves.
    Widget gridBtn = AnimatedOpacity(
      duration: $styles.times.fast,
      opacity: isSelected ? 1 : 0.4,
      child: AnimatedContainer(
        duration: $styles.times.fast,
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular($styles.corners.md + 4),
          border: Border.all(
            color: isSelected ? accent : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular($styles.corners.md),
          child: SizedBox(
            width: size,
            height: size,
            child: AppBtn(
              bgColor: btnData.type.fgColor,
              onPressed: widget.onPressed,
              padding: EdgeInsets.zero,
              semanticLabel: btnData.title,
              child: SizedBox.expand(
                child: kIsWeb
                    ? AnimatedScale(
                        alignment: Alignment.center,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        scale: _isOver ? 1.1 : 1.0,
                        child: iconImage,
                      )
                    : iconImage,
              ),
            ),
          ),
        ),
      ),
    );

    return kIsWeb
        ? MouseRegion(
            onEnter: (_) => setState(() => _isOver = true),
            onExit: (_) => setState(() => _isOver = false),
            child: gridBtn,
          )
        : gridBtn;
  }
}

class _MenuTextBtn extends StatelessWidget {
  const _MenuTextBtn({required this.label, required this.onPressed, required this.icon});
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppBtn(
      expand: true,
      padding: EdgeInsets.symmetric(vertical: $styles.insets.md),
      onPressed: onPressed,
      bgColor: Colors.transparent,
      semanticLabel: label,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: $styles.colors.offWhite, size: 20),
          Gap($styles.insets.xs),
          Text(label, style: $styles.text.bodyBold.copyWith(height: 1)),
        ],
      ),
    );
  }
}
