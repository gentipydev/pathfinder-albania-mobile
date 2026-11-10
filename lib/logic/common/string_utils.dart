import 'package:travel_buddy/common_libs.dart';

class StringUtils {
  static Size measure(
    String text,
    TextStyle style, {
    int maxLines = 1,
    TextDirection direction = TextDirection.ltr,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: direction,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static String formatYr(int yr) {
    if (yr == 0) yr = 1;
    return $strings.yearFormat(yr.abs().toString(), getYrSuffix(yr));
  }

  static String getYrSuffix(int yr) => yr < 0 ? $strings.yearBCE : $strings.yearCE;

  /// Formats a period's end year; null means the place is still lived in.
  static String formatEndYr(int? yr) => yr == null ? $strings.yearToday : formatYr(yr);

  /// Albanian periods: antiquity ends with the Western Roman Empire (476),
  /// the Middle Ages with the Ottoman conquest (Krujë 1478, Shkodër 1479)
  /// and the Ottoman era with independence (1912).
  static String getEra(int yr) {
    if (yr < -800) return $strings.eraPrehistory;
    if (yr < 476) return $strings.eraAntiquity;
    if (yr < 1479) return $strings.eraMiddleAges;
    if (yr < 1912) return $strings.eraOttoman;
    return $strings.eraModern;
  }

  static String capitalize(String value) {
    return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
  }
}
