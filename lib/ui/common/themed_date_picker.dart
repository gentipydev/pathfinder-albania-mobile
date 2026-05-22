import 'package:travel_buddy/common_libs.dart';

/// App-themed wrapper around Material's [showDatePicker].
///
/// The app's global [ColorScheme] sets `onSurface = white` because most
/// screens paint text over hero images. Inside a Material 3 date picker
/// `onSurface` drives day numbers, weekday labels, and the headline — so
/// the default picker renders white-on-cream and reads as invisible. This
/// helper layers a local theme that fixes contrast and aligns the picker
/// with `$styles` (cream surface, accent1 selection, app fonts).
Future<DateTime?> showThemedDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  required String helpText,
  Locale? locale,
}) {
  final colors = $styles.colors;
  final base = Theme.of(context);
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: helpText,
    locale: locale,
    builder: (context, child) {
      return Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: colors.accent1,
            onPrimary: colors.white,
            surface: colors.offWhite,
            onSurface: colors.greyStrong,
            onSurfaceVariant: colors.body,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: colors.offWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            headerBackgroundColor: colors.offWhite,
            headerForegroundColor: colors.greyStrong,
            headerHelpStyle: $styles.text.bodySmall.copyWith(
              color: colors.caption,
            ),
            headerHeadlineStyle: $styles.text.h3.copyWith(
              color: colors.greyStrong,
              fontWeight: FontWeight.w600,
            ),
            weekdayStyle: $styles.text.bodySmallBold.copyWith(
              color: colors.caption,
              letterSpacing: 0.5,
            ),
            dayStyle: $styles.text.body.copyWith(color: colors.body),
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colors.greyMedium.withValues(alpha: 0.45);
              }
              if (states.contains(WidgetState.selected)) {
                return colors.white;
              }
              return colors.body;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return colors.accent1;
              return null;
            }),
            dayOverlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return colors.accent1.withValues(alpha: 0.12);
              }
              return null;
            }),
            todayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return colors.white;
              return colors.accent1;
            }),
            todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return colors.accent1;
              return null;
            }),
            todayBorder: BorderSide(color: colors.accent1, width: 1),
            yearStyle: $styles.text.body.copyWith(color: colors.body),
            yearForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colors.greyMedium.withValues(alpha: 0.45);
              }
              if (states.contains(WidgetState.selected)) return colors.white;
              return colors.body;
            }),
            yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return colors.accent1;
              return null;
            }),
            dividerColor: colors.greyMedium.withValues(alpha: 0.25),
            cancelButtonStyle: TextButton.styleFrom(
              foregroundColor: colors.accent1,
              textStyle: $styles.text.bodySmallBold,
            ),
            confirmButtonStyle: TextButton.styleFrom(
              foregroundColor: colors.accent1,
              textStyle: $styles.text.bodySmallBold,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: colors.accent1),
          ),
          iconTheme: IconThemeData(color: colors.body),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: $styles.text.bodySmall.copyWith(color: colors.caption),
            hintStyle: $styles.text.body.copyWith(color: colors.greyMedium),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: colors.greyMedium.withValues(alpha: 0.35),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.accent1, width: 2),
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
