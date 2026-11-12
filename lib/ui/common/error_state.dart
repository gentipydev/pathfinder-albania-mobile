import 'package:pathfinder_albania/common_libs.dart';

/// Reusable inline error placeholder. Used at the body level of list-shaped
/// screens when an initial load failed and there's no usable cached data
/// to render. Inline rather than overlay per `feedback_no_snackbar`; pairs
/// with the transient `TripErrorBanner` (which handles mutation errors on
/// top of a populated list).
///
/// Lifted from the prior local `_ErrorView` in `conversations_screen.dart`
/// (deleted as part of the same change). The retry-button label intentionally
/// reuses `$strings.buddyErrorRetry` to match the prior visual.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all($styles.insets.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: colors.greyMedium),
            Gap($styles.insets.sm),
            Text(
              message,
              style: $styles.text.body.copyWith(color: colors.greyMedium),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              Gap($styles.insets.md),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  $strings.buddyErrorRetry,
                  style: $styles.text.bodyBold.copyWith(color: colors.accent1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
