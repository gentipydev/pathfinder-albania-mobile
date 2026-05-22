import 'package:travel_buddy/common_libs.dart';

/// Shared bottom-sheet for destructive confirmations across the app.
///
/// Returns `true` only when the destructive tile is tapped; scrim dismiss,
/// drag-down, and the cancel tile all return `false`.
Future<bool> showDestructiveConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  IconData confirmIcon = Icons.delete_outline,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: $styles.colors.greyStrong,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular($styles.corners.md),
      ),
    ),
    builder: (sheetCtx) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: $styles.insets.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                $styles.insets.lg,
                0,
                $styles.insets.lg,
                $styles.insets.xs,
              ),
              child: Text(
                title,
                style: $styles.text.bodyBold
                    .copyWith(color: $styles.colors.offWhite),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                $styles.insets.lg,
                0,
                $styles.insets.lg,
                $styles.insets.sm,
              ),
              child: Text(
                body,
                style: $styles.text.body
                    .copyWith(color: $styles.colors.greyMedium),
              ),
            ),
            ListTile(
              leading: Icon(confirmIcon, color: Colors.redAccent),
              title: Text(
                confirmLabel,
                style: $styles.text.bodyBold.copyWith(color: Colors.redAccent),
              ),
              onTap: () => Navigator.of(sheetCtx).pop(true),
            ),
            ListTile(
              leading: Icon(Icons.close, color: $styles.colors.offWhite),
              title: Text(
                cancelLabel,
                style: $styles.text.bodyBold
                    .copyWith(color: $styles.colors.offWhite),
              ),
              onTap: () => Navigator.of(sheetCtx).pop(false),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
