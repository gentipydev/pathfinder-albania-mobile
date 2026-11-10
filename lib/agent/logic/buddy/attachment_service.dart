import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Why an attachment was rejected before upload. The UI maps this to an
/// inline, localized message on the attachment control (no snackbar).
enum AttachmentRejectReason { unsupportedFormat, tooLarge }

/// Thrown by [AttachmentService.upload] when a file fails the pre-upload
/// size/format checks, so the caller can surface inline feedback instead of
/// shipping an oversized or non-image blob to storage.
class AttachmentException implements Exception {
  AttachmentException(this.reason);
  final AttachmentRejectReason reason;

  @override
  String toString() => 'AttachmentException($reason)';
}

class AttachmentService {
  AttachmentService({this.maxBytes = 10 * 1024 * 1024}); // 10 MB

  static const String _bucket = 'chat-attachments';

  /// Hard ceiling on a single attachment. Anthropic's vision input and the
  /// backend's multimodal path both reject very large images; bounding here
  /// avoids a slow upload that the model would refuse anyway. Injectable so
  /// tests can exercise the size gate without allocating a 10 MB file.
  final int maxBytes;

  /// Image formats Anthropic vision accepts. Anything else (heic, bmp, pdf, …)
  /// is rejected up front rather than silently coerced to a jpg content-type.
  static const Set<String> allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  };

  final _uuid = const Uuid();

  Future<String> upload(XFile file, {required String userId}) async {
    final ext = _extensionFor(file);
    if (!allowedExtensions.contains(ext)) {
      throw AttachmentException(AttachmentRejectReason.unsupportedFormat);
    }
    // Check size via file length before reading the whole file into memory.
    final size = await file.length();
    if (size > maxBytes) {
      throw AttachmentException(AttachmentRejectReason.tooLarge);
    }

    final bytes = await file.readAsBytes();
    final contentType = _contentTypeFor(ext);
    final path = '$userId/${_uuid.v4()}.$ext';

    debugPrint(
        '[AttachmentService] upload start: bucket=$_bucket path=$path size=${bytes.length} contentType=$contentType');
    final storage = Supabase.instance.client.storage.from(_bucket);
    try {
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: contentType),
      );
      final url = storage.getPublicUrl(path);
      debugPrint('[AttachmentService] upload ok: url=$url');
      return url;
    } catch (err, st) {
      debugPrint('[AttachmentService] upload failed: $err');
      developer.log(
        'Supabase upload failed: bucket=$_bucket path=$path size=${bytes.length} contentType=$contentType',
        name: 'AttachmentService',
        error: err,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// The file's real lowercase extension (without the dot), or '' when the
  /// name has none. Returning the actual extension — rather than coercing
  /// unknowns to 'jpg' — is what lets the allow-list reject non-images.
  String _extensionFor(XFile file) {
    final name = file.name.toLowerCase();
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return '';
    return name.substring(dot + 1);
  }

  String _contentTypeFor(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
