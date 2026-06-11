import 'package:flutter_web_plugins/url_strategy.dart';

/// Path-based URLs (no `/#/`) on web. The hosting layer must rewrite all
/// paths to index.html (SPA rewrite) so deep links survive a hard refresh —
/// e.g. Firebase Hosting: `"rewrites": [{"source": "**", "destination":
/// "/index.html"}]`.
void configureUrlStrategy() => usePathUrlStrategy();
