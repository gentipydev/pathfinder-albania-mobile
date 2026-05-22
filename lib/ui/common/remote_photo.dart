import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/common/retry_image.dart';

/// Renders a remote photo from a URL. Wrapped in `RetryImage` so transient
/// network blips don't leave a blank frame. Used for backend-supplied
/// public Supabase Storage URLs (destination galleries, artifact images).
class RemotePhoto extends StatelessWidget {
  const RemotePhoto(this.url, {super.key, this.fit = BoxFit.cover});
  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return AppImage(
      image: url.isEmpty ? null : RetryImage(NetworkImage(url)),
      fit: fit,
      progress: true,
      scale: 1,
    );
  }
}
