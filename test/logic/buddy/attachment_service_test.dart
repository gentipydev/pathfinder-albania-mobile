import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy/logic/buddy/attachment_service.dart';

/// These exercise the pre-upload validation, which short-circuits BEFORE any
/// Supabase call — so no network / plugin init is needed. A valid file's
/// success path is not covered here because it would require a live storage
/// client.
///
/// Real temp files are used (not `XFile.fromData`) because the in-memory
/// constructor doesn't carry a usable `.name` in the test VM, and the format
/// gate reads the extension off the name.
void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('att_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  XFile fileNamed(String name, {int bytes = 16}) {
    final f = File('${tmp.path}/$name')..writeAsBytesSync(Uint8List(bytes));
    return XFile(f.path);
  }

  Matcher rejectsWith(AttachmentRejectReason reason) => throwsA(
        isA<AttachmentException>().having((e) => e.reason, 'reason', reason),
      );

  test('rejects an unsupported format before upload', () async {
    await expectLater(
      () => AttachmentService().upload(fileNamed('photo.heic'), userId: 'u1'),
      rejectsWith(AttachmentRejectReason.unsupportedFormat),
    );
  });

  test('rejects a file with no extension', () async {
    await expectLater(
      () => AttachmentService().upload(fileNamed('photo'), userId: 'u1'),
      rejectsWith(AttachmentRejectReason.unsupportedFormat),
    );
  });

  test('rejects an oversized image before upload', () async {
    // Tiny limit so we don't allocate a real 10 MB file.
    final svc = AttachmentService(maxBytes: 8);
    await expectLater(
      () => svc.upload(fileNamed('photo.png', bytes: 16), userId: 'u1'),
      rejectsWith(AttachmentRejectReason.tooLarge),
    );
  });

  test('accepts an allowed extension case-insensitively', () async {
    // Valid format + size passes validation, then fails at the (uninitialized)
    // Supabase call — so it must throw something that is NOT our validation
    // exception, proving it got past the gate.
    await expectLater(
      () => AttachmentService().upload(fileNamed('PHOTO.JPG'), userId: 'u1'),
      throwsA(isNot(isA<AttachmentException>())),
    );
  });
}
