import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/agent/features/auth/bloc/auth_bloc.dart';
import 'package:travel_buddy/agent/features/auth/bloc/auth_state.dart';

class AttachButton extends StatelessWidget {
  const AttachButton({super.key, required this.onPicked});

  final ValueChanged<XFile> onPicked;

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: $styles.colors.greyStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular($styles.corners.md),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt_rounded,
                color: $styles.colors.offWhite,
              ),
              title: Text(
                $strings.buddyAttachCamera,
                style: $styles.text.body.copyWith(
                  color: $styles.colors.offWhite,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_rounded,
                color: $styles.colors.offWhite,
              ),
              title: Text(
                $strings.buddyAttachGallery,
                style: $styles.text.body.copyWith(
                  color: $styles.colors.offWhite,
                ),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file != null) onPicked(file);
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, bool>(
      selector: (s) => s.isAuthenticated,
      builder: (ctx, signedIn) {
        if (!signedIn) return const SizedBox.shrink();
        return Tooltip(
          message: $strings.buddyAttachTooltip,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _pick(ctx),
              child: SizedBox(
                height: 44,
                width: 44,
                child: Icon(
                  Icons.add_rounded,
                  color: $styles.colors.offWhite,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
