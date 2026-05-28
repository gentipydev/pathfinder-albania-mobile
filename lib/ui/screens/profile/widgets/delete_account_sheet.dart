import 'package:travel_buddy/common_libs.dart';

/// Type-to-confirm bottom sheet for destructive account deletion. Returns
/// `true` only when the user typed the confirmation word AND tapped the
/// destructive action; scrim dismiss, drag-down, and Cancel return `false`.
///
/// The confirmation word is locale-aware — pass whatever `$strings`
/// resolves to so the visible-text and the type-target stay in sync if
/// the locale changes mid-flow.
///
/// Inline error: if the caller's delete attempt fails, pass `errorMessage`
/// the next time you `showDeleteAccountSheet(...)` and it'll render above
/// the field. We don't reopen the sheet automatically — the caller decides
/// whether to retry.
Future<bool> showDeleteAccountSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String instruction,
  required String confirmWord,
  required String confirmLabel,
  required String cancelLabel,
  String? errorMessage,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: $styles.colors.greyStrong,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular($styles.corners.md),
      ),
    ),
    builder: (sheetCtx) {
      return SafeArea(
        top: false,
        child: Padding(
          // Lift the sheet above the keyboard while the user is typing.
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: _DeleteAccountForm(
            title: title,
            body: body,
            instruction: instruction,
            confirmWord: confirmWord,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            errorMessage: errorMessage,
          ),
        ),
      );
    },
  );
  return result ?? false;
}

class _DeleteAccountForm extends StatefulWidget {
  const _DeleteAccountForm({
    required this.title,
    required this.body,
    required this.instruction,
    required this.confirmWord,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.errorMessage,
  });

  final String title;
  final String body;
  final String instruction;
  final String confirmWord;
  final String confirmLabel;
  final String cancelLabel;
  final String? errorMessage;

  @override
  State<_DeleteAccountForm> createState() => _DeleteAccountFormState();
}

class _DeleteAccountFormState extends State<_DeleteAccountForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _matches => _controller.text.trim() == widget.confirmWord;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Column(
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
            widget.title,
            style: $styles.text.bodyBold.copyWith(color: colors.offWhite),
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
            widget.body,
            style: $styles.text.body.copyWith(color: colors.greyMedium),
          ),
        ),
        if (widget.errorMessage != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              $styles.insets.lg,
              0,
              $styles.insets.lg,
              $styles.insets.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: $styles.colors.error, size: 18),
                Gap($styles.insets.xs),
                Expanded(
                  child: Text(
                    widget.errorMessage!,
                    style: $styles.text.bodySmall.copyWith(color: $styles.colors.error),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            $styles.insets.lg,
            0,
            $styles.insets.lg,
            $styles.insets.xs,
          ),
          child: Text(
            widget.instruction,
            style: $styles.text.bodySmall.copyWith(color: colors.greyMedium),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            $styles.insets.lg,
            0,
            $styles.insets.lg,
            $styles.insets.sm,
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            style: $styles.text.body.copyWith(color: colors.offWhite),
            decoration: InputDecoration(
              hintText: widget.confirmWord,
              hintStyle: $styles.text.body.copyWith(color: colors.greyMedium),
              filled: true,
              fillColor: colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular($styles.corners.sm),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_matches) Navigator.of(context).pop(true);
            },
          ),
        ),
        ListTile(
          enabled: _matches,
          leading: Icon(
            Icons.delete_forever,
            color: _matches ? colors.error : colors.greyMedium,
          ),
          title: Text(
            widget.confirmLabel,
            style: $styles.text.bodyBold.copyWith(
              color: _matches ? colors.error : colors.greyMedium,
            ),
          ),
          onTap: _matches ? () => Navigator.of(context).pop(true) : null,
        ),
        ListTile(
          leading: Icon(Icons.close, color: colors.offWhite),
          title: Text(
            widget.cancelLabel,
            style: $styles.text.bodyBold.copyWith(color: colors.offWhite),
          ),
          onTap: () => Navigator.of(context).pop(false),
        ),
        Gap($styles.insets.sm),
      ],
    );
  }
}
