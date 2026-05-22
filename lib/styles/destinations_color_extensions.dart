import 'package:travel_buddy/common_libs.dart';

extension DestinationColorExtensions on DestinationType {
  Color get bgColor {
    return switch (this) {
      DestinationType.albanianAlps => const Color(0xFF16184D),
      DestinationType.apollonia => const Color(0xFF642828),
      DestinationType.kruja => const Color(0xFF444B9B),
      DestinationType.gjirokaster => const Color(0xFF1E736D),
      DestinationType.butrint => const Color(0xFF164F2A),
      DestinationType.theth => const Color(0xFF0E4064),
      DestinationType.korca => const Color(0xFFC96454),
      DestinationType.berat => const Color(0xFF1C4D46),
    };
  }

  Color get fgColor {
    return switch (this) {
      DestinationType.albanianAlps => const Color(0xFF444B9B),
      DestinationType.apollonia => const Color(0xFF688750),
      DestinationType.kruja => const Color(0xFF1B1A65),
      DestinationType.gjirokaster => const Color(0xFF4AA39D),
      DestinationType.butrint => const Color(0xFFE2CFBB),
      DestinationType.theth => const Color(0xFFC1D9D1),
      DestinationType.korca => const Color(0xFF642828),
      DestinationType.berat => const Color(0xFFED7967),
    };
  }
}

extension ColorFilterOnColor on Color {
  ColorFilter get colorFilter => ColorFilter.mode(this, BlendMode.srcIn);
}
