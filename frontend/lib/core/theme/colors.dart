import 'package:flutter/material.dart';

/// The "Private Edition" palette. Editorial, analog, not neon.
///
/// Dominant tones are the cream paper and deep ink. Oxblood is the
/// emphatic voice — CTAs, editor's marks, drop caps. Sage marks
/// completion; mustard marks streaks or earned highlights.
class AppColors {
  const AppColors._();

  static const Color paper = Color(0xFFF5F1E8);
  static const Color cardInset = Color(0xFFEDE6D5);
  static const Color ink = Color(0xFF1A1A1A);
  static const Color inkSoft = Color(0xFF3A3A38);

  static const Color oxblood = Color(0xFF8C2727);
  static const Color sage = Color(0xFF7A8C6A);
  static const Color mustard = Color(0xFFE8D98A);

  static const Color ruleGray = Color(0xFFC8C1AE);
  static const Color ruleGrayStrong = Color(0xFFA8A18E);

  /// A very faint wash used for subtle chart fills.
  static const Color oxbloodWash = Color(0x148C2727);
}
