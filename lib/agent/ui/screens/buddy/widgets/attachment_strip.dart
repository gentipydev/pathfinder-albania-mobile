import 'dart:io';

import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/agent/logic/buddy/attachment.dart';

class AttachmentStrip extends StatelessWidget {
  const AttachmentStrip({
    super.key,
    required this.attachments,
    required this.onRemove,
    required this.onRetry,
  });

  final List<PendingAttachment> attachments;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onRetry;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(
        left: $styles.insets.sm,
        right: $styles.insets.sm,
        bottom: $styles.insets.xs,
      ),
      child: SizedBox(
        height: 76,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: attachments.length,
          separatorBuilder: (_, _) => Gap($styles.insets.xs),
          itemBuilder: (ctx, i) => _AttachmentChip(
            attachment: attachments[i],
            onRemove: () => onRemove(attachments[i].id),
            onRetry: () => onRetry(attachments[i].id),
          ),
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.attachment,
    required this.onRemove,
    required this.onRetry,
  });

  final PendingAttachment attachment;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final isFailed = attachment.status == AttachmentStatus.failed;
    final isUploading = attachment.status == AttachmentStatus.uploading;
    final chip = SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular($styles.corners.sm),
              child: ColorFiltered(
                colorFilter: isFailed
                    ? ColorFilter.mode(
                        $styles.colors.error.withValues(alpha: .5),
                        BlendMode.srcATop,
                      )
                    : const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.dst,
                      ),
                child: Image.file(
                  File(attachment.localPath),
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular($styles.corners.sm),
                ),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.accent1,
                    ),
                  ),
                ),
              ),
            ),
          if (isFailed)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  color: Colors.black.withValues(alpha: .7),
                  child: Text(
                    $strings.buddyAttachRetry,
                    textAlign: TextAlign.center,
                    style: $styles.text.caption.copyWith(color: colors.offWhite),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colors.offWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (isFailed && (attachment.errorMessage?.isNotEmpty ?? false)) {
      return Tooltip(
        message: attachment.errorMessage!,
        triggerMode: TooltipTriggerMode.longPress,
        showDuration: const Duration(seconds: 6),
        child: chip,
      );
    }
    return chip;
  }
}
