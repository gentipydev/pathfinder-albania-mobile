import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/common/platform_info.dart';
import 'package:travel_buddy/ui/common/modals/fullscreen_web_view.dart';

class AboutDialogContent extends StatelessWidget {
  const AboutDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    void handleTap(String url) {
      if (PlatformInfo.isDesktopOrWeb) {
        launchUrl(Uri.parse(url));
      } else {
        Navigator.push(context, CupertinoPageRoute(builder: (_) => FullscreenWebView(url)));
      }
    }

    List<TextSpan> buildSpan(String text, {Map<String, List<String>>? linkSupplants}) {
      if (linkSupplants?.isNotEmpty ?? false) {
        final r = RegExp(r'\{\w+\}');
        final matches = r.allMatches(text);
        final a = text.split(r);

        final supplantKeys = matches.map((x) => x.group(0));
        final sortedEntries = supplantKeys.map(
          (x) => linkSupplants?.entries.firstWhere((e) => e.key == x),
        );

        final spans = <TextSpan>[];
        for (var i = 0; i < a.length; i++) {
          spans.add(TextSpan(text: a[i]));
          if (i < sortedEntries.length) {
            final label = sortedEntries.elementAt(i)!.value[0];
            final link = sortedEntries.elementAt(i)!.value[1];
            spans.add(
              TextSpan(
                text: label,
                recognizer: TapGestureRecognizer()..onTap = () => handleTap(link),
                style: TextStyle(fontWeight: FontWeight.bold, color: $styles.colors.accent1),
              ),
            );
          }
        }
        return spans;
      } else {
        return [TextSpan(text: text)];
      }
    }

    double fontSize = $styles.text.body.fontSize!;
    fontSize = MediaQuery.textScalerOf(context).scale(fontSize);
    return SingleChildScrollView(
      child: Column(
        children: [
          Gap($styles.insets.sm),
          RichText(
            text: TextSpan(
              style: $styles.text.bodySmall.copyWith(color: Colors.black, fontSize: fontSize),
              children: [
                ...buildSpan($strings.homeMenuAboutTagline),
                ...buildSpan(
                  $strings.homeMenuAboutBuilt('{flutterUrl}'),
                  linkSupplants: {
                    '{flutterUrl}': [$strings.homeMenuAboutFlutter, 'https://flutter.dev'],
                  },
                ),
                ...buildSpan('\n\n'),
                ...buildSpan(
                  '${$strings.homeMenuAboutLearn('{appUrl}')} ',
                  linkSupplants: {
                    // TODO(rebrand): point at the live Travel Buddy marketing
                    // site once it's published.
                    '{appUrl}': [
                      $strings.homeMenuAboutApp,
                      'https://travelbuddy.app/',
                    ],
                  },
                ),
                ...buildSpan(
                  $strings.homeMenuAboutSource('{githubUrl}'),
                  linkSupplants: {
                    // TODO(rebrand): replace with the real Travel Buddy github
                    // repo URL once the project is pushed publicly.
                    '{githubUrl}': [
                      ($strings.homeMenuAboutRepo),
                      'https://github.com/travel-buddy/travel-buddy-mobile',
                    ],
                  },
                ),
                ...buildSpan(
                  ' ${$strings.privacyStatement('{privacyUrl}')}',
                  linkSupplants: {
                    // TODO(rebrand): replace with the real Travel Buddy privacy
                    // policy URL once it's published.
                    '{privacyUrl}': [
                      $strings.privacyPolicy,
                      'https://travelbuddy.app/privacy/',
                    ],
                  },
                ),
                ...buildSpan('\n\n'),
                ...buildSpan(
                  '${$strings.homeMenuAboutPublic('{metUrl}')} ',
                  linkSupplants: {
                    '{metUrl}': [
                      $strings.homeMenuAboutMet,
                      'https://www.metmuseum.org/about-the-met/policies-and-documents/open-access',
                    ],
                  },
                ),
                ...buildSpan(
                  $strings.homeMenuAboutPhotography('{unsplashUrl}'),
                  linkSupplants: {
                    // TODO(rebrand): replace with the Travel Buddy Unsplash
                    // collection URL once curated.
                    '{unsplashUrl}': [
                      $strings.homeMenuAboutUnsplash,
                      'https://unsplash.com/',
                    ],
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
