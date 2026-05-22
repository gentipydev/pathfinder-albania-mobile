enum AttachmentStatus { uploading, ready, failed }

class PendingAttachment {
  PendingAttachment({required this.id, required this.localPath})
      : status = AttachmentStatus.uploading,
        progress = 0;

  final String id;
  final String localPath;
  AttachmentStatus status;
  double progress;
  String? remoteUrl;
  String? errorMessage;
}
