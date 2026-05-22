import 'package:travel_buddy/common_libs.dart';

/// Reusable inline empty-state placeholder. Used at the body level of list-
/// shaped screens (My Trips, Conversations, etc.) when a successful load
/// returned zero items. Inline rather than overlay per `feedback_no_snackbar`.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: $styles.insets.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: colors.greyMedium),
            SizedBox(height: $styles.insets.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: $styles.text.bodyBold.copyWith(color: colors.offWhite),
            ),
            if (subtitle != null) ...[
              SizedBox(height: $styles.insets.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: $styles.text.bodySmall.copyWith(color: colors.greyMedium),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: $styles.insets.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
