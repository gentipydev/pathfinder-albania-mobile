import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AttachmentService {
  static const String _bucket = 'chat-attachments';
  final _uuid = const Uuid();

  Future<String> upload(XFile file, {required String userId}) async {
    final bytes = await file.readAsBytes();
    final ext = _extensionFor(file);
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

  String _extensionFor(XFile file) {
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'png';
    if (name.endsWith('.webp')) return 'webp';
    return 'jpg';
  }

  String _contentTypeFor(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
