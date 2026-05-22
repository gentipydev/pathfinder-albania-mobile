import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/features/settings/bloc/settings_bloc.dart';
import 'package:travel_buddy/features/settings/bloc/settings_state.dart';
import 'package:travel_buddy/logic/common/animate_utils.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';
import 'package:travel_buddy/ui/common/app_backdrop.dart';
import 'package:travel_buddy/ui/common/app_icons.dart';
import 'package:travel_buddy/ui/common/controls/app_header.dart';
import 'package:travel_buddy/ui/common/controls/locale_switcher.dart';
import 'package:travel_buddy/ui/common/pop_navigator_underlay.dart';
import 'package:travel_buddy/ui/common/utils/duration_utils.dart';
import 'package:travel_buddy/ui/common/travel_buddy_logo.dart';
import 'package:travel_buddy/ui/screens/home_menu/about_dialog_content.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key, required this.data});
  final DestinationData data;

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  double _btnSize(BuildContext context) => (context.sizePx.shortestSide / 5).clamp(60, 100);

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

  void _handleCollectionPressed(BuildContext context) => context.go(ScreenPaths.collection(''));

  void _handleTimelinePressed(BuildContext context) => context.go(ScreenPaths.timeline(widget.data.type));

  @override
  Widget build(BuildContext context) {
    final double gridWidth = _btnSize(context) * 3 * 1.2;
    return Stack(
      children: [
        /// Backdrop / Underlay
        AppBackdrop(
          strength: .5,
          child: Container(color: $styles.colors.greyStrong.withValues(alpha: 0.5)),
        ),

        PopNavigatorUnderlay(),

        /// Content
        SafeArea(
          child: Center(
            child: SizedBox(
              width: gridWidth,
              child: ExpandedScrollingColumn(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Gap(50),
                  Gap($styles.insets.md),
                  _buildIconGrid(context)
                      .maybeAnimate()
                      .fade(duration: $styles.times.fast)
                      .scale(begin: Offset(.8, .8), curve: Curves.easeOut),
                  Gap($styles.insets.lg),
                  _buildBottomBtns(context),
                  //Spacer(),
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

  Widget _buildIconGrid(BuildContext context) {
    Widget buildRow(List<Widget> children) => SeparatedRow(
      mainAxisAlignment: MainAxisAlignment.center,
      separatorBuilder: () => Gap($styles.insets.sm),
      children: children,
    );
    return SeparatedColumn(
      separatorBuilder: () => Gap($styles.insets.sm),
      mainAxisSize: MainAxisSize.min,
      children: [
        buildRow([
          _GridBtn(destinationsLogic.all[0], widget.data),
          _GridBtn(destinationsLogic.all[1], widget.data),
          _GridBtn(destinationsLogic.all[2], widget.data),
        ]),
        buildRow([
          _GridBtn(destinationsLogic.all[3], widget.data),
          SizedBox(
            width: _btnSize(context),
            child: SvgPicture.asset(
              SvgPaths.compassFull,
              colorFilter: $styles.colors.offWhite.colorFilter,
            ),
          ),
          _GridBtn(destinationsLogic.all[4], widget.data),
        ]),
        buildRow([
          _GridBtn(destinationsLogic.all[5], widget.data),
          _GridBtn(destinationsLogic.all[6], widget.data),
          _GridBtn(destinationsLogic.all[7], widget.data),
        ]),
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
                      label: $strings.homeMenuButtonExplore,
                      icon: AppIcons.timeline,
                      onPressed: () => _handleTimelinePressed(context),
                    ),
                    _MenuTextBtn(
                      label: $strings.homeMenuButtonView,
                      icon: AppIcons.collection,
                      onPressed: () => _handleCollectionPressed(context),
                    ),
                    _MenuTextBtn(
                      label: $strings.homeMenuButtonAbout,
                      icon: AppIcons.info,
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

class _GridBtn extends StatefulWidget {
  const _GridBtn(this.btnData, this.selectedData);
  final DestinationData btnData;
  final DestinationData selectedData;
  double _btnSize(BuildContext context) => (context.sizePx.shortestSide / 5).clamp(60, 100);

  @override
  State<_GridBtn> createState() => _GridBtnState();
}

class _GridBtnState extends State<_GridBtn> {
  bool _isOver = false;

  void _handleDestinationPressed(BuildContext context, DestinationData data) => Navigator.pop(context, data.type);

  @override
  Widget build(BuildContext context) {
    DestinationData btnData = widget.btnData;
    bool isSelected = btnData == widget.selectedData;

    Widget iconImage = Image.asset(btnData.type.homeBtn, fit: BoxFit.cover);

    Widget gridBtn = Container(
      width: widget._btnSize(context),
      height: widget._btnSize(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular($styles.corners.md),
        boxShadow: !isSelected
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 3,
                  spreadRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular($styles.corners.md),
        child: AppBtn(
          border: !isSelected ? null : BorderSide(color: $styles.colors.offWhite, width: 5),
          bgColor: btnData.type.fgColor,
          onPressed: () => _handleDestinationPressed(context, btnData),
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
  final AppIcons icon;

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
          AppIcon(icon, color: $styles.colors.offWhite),
          Gap($styles.insets.xs),
          Text(label, style: $styles.text.bodyBold.copyWith(height: 1)),
        ],
      ),
    );
  }
}
