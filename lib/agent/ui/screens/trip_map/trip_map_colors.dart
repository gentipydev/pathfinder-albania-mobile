import 'package:flutter/material.dart';

/// Mirrors `_DAY_COLORS` in travel-buddy-backend/app/services/static_map.py.
/// Backend uses 0-based day_index; Flutter uses 1-based dayNumber.
///
/// Warm Mediterranean palette anchored on AppColors.accent1 — earthy tones
/// that read against any map terrain while staying in the brand's family.
const kDayColors = <Color>[
  Color(0xFFE4935D), // Day 1 — accent1 (brand warm orange)
  Color(0xFFA8453E), // Day 2 — terracotta (Albanian rooftops)
  Color(0xFFC9A55A), // Day 3 — warm gold (Mediterranean light)
  Color(0xFF6B8E5C), // Day 4 — olive sage
  Color(0xFF5A7A8E), // Day 5 — Adriatic slate
];

Color colorForDayNumber(int dayNumber) =>
    kDayColors[(dayNumber - 1) % kDayColors.length];
