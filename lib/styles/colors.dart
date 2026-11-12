import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/common/color_utils.dart';

export 'destinations_color_extensions.dart';

class AppColors {
  /// Common
  final Color accent1 = Color(0xFFE4935D);
  final Color accent2 = Color(0xFFBEABA1);
  final Color accent3 = Color(0xFFC47642);
  final Color offWhite = Color(0xFFF8ECE5);
  final Color caption = const Color(0xFF7D7873);
  final Color body = const Color(0xFF514F4D);
  final Color greyStrong = const Color(0xFF272625);
  final Color greyMedium = const Color(0xFF9D9995);
  final Color white = Colors.white;
  // NOTE: If this color is changed, also change it in
  // - web/manifest.json
  // - web/index.html -
  final Color black = const Color(0xFF1E1B18);

  /// Warm, brand-aligned red for error / destructive states.
  final Color error = const Color(0xFFD9534F);

  /// Elevated dark surface, one step above [black], for cards / chips / sheets.
  final Color surface = const Color(0xFF242120);

  Color shift(Color c, double d) => ColorUtils.shiftHsl(c, d);

  ThemeData toThemeData() {
    /// Create a TextTheme and ColorScheme, that we can use to generate ThemeData
    TextTheme txtTheme = ThemeData.light().textTheme;
    Color txtColor = white;
    ColorScheme colorScheme = ColorScheme(
      // Map our custom theme to the Material ColorScheme
      brightness: Brightness.light,
      primary: accent1,
      primaryContainer: accent1,
      secondary: accent1,
      secondaryContainer: accent1,
      surface: offWhite,
      onSurface: txtColor,
      onError: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      error: error,
    );

    /// Now that we have ColorScheme and TextTheme, we can create the ThemeData
    /// Also add on some extra properties that ColorScheme seems to miss
    var t = ThemeData.from(textTheme: txtTheme, colorScheme: colorScheme).copyWith(
      textSelectionTheme: TextSelectionThemeData(cursorColor: accent1),
      highlightColor: accent1,
    );

    /// Return the themeData which MaterialApp can now use
    return t;
  }
}
