import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/ui/common/themed_text.dart';

Future<bool?> showModal(BuildContext context, {required Widget child}) async {
  return await showModalBottomSheet(
        context: context,
        backgroundColor: $styles.colors.greyStrong,
        builder: (_) => child,
      ) ??
      false;
}

class OkCancelModal extends StatelessWidget {
  const OkCancelModal({super.key, this.msg});
  final String? msg;

  @override
  Widget build(BuildContext context) {
    return _BaseContentModal(
      msg: msg,
      buttons: [
        AppBtn.from(
          text: $strings.appModalsButtonOk,
          expand: true,
          isSecondary: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        Gap($styles.insets.xs),
        AppBtn.from(
          text: $strings.appModalsButtonCancel,
          expand: true,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}

/// A message above a column of buttons.
class _BaseContentModal extends StatelessWidget {
  final String? msg;
  final List<Widget> buttons;

  const _BaseContentModal({this.msg, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Center(
        child: SizedBox(
          width: $styles.sizes.maxContentWidth3,
          child: Padding(
            padding: EdgeInsets.all($styles.insets.lg),
            child: LightText(
              child: SeparatedColumn(
                mainAxisSize: MainAxisSize.min,
                separatorBuilder: () => Gap($styles.insets.md),
                children: [
                  if (msg != null) Text(msg!, style: $styles.text.body),
                  Gap($styles.insets.md),
                  Column(children: buttons.map((e) => e).toList()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
