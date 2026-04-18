import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Typography for the "Private Edition": Fraunces as the editorial voice,
/// IBM Plex Sans for chrome, IBM Plex Mono for every number we print.
///
/// Fraunces carries the italic "coach speaking" voice; roman is reserved
/// for facts, data, and labels. Never use Inter or system-ui.
class AppTypography {
  const AppTypography._();

  static TextStyle _fraunces({
    required double size,
    FontWeight weight = FontWeight.w400,
    FontStyle style = FontStyle.normal,
    double? height,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle _plex({
    required double size,
    FontWeight weight = FontWeight.w400,
    double? height,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    return GoogleFonts.ibmPlexSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle _mono({
    required double size,
    FontWeight weight = FontWeight.w400,
    double? height,
    Color color = AppColors.ink,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      fontFeatures: const [
        FontFeature.tabularFigures(),
        FontFeature.liningFigures(),
      ],
    );
  }

  // --- Display / editorial -------------------------------------------------

  static TextStyle get display => _fraunces(
        size: 48,
        weight: FontWeight.w500,
        height: 1.05,
        letterSpacing: -0.5,
      );

  static TextStyle get title => _fraunces(
        size: 32,
        weight: FontWeight.w500,
        height: 1.1,
        letterSpacing: -0.3,
      );

  static TextStyle get headline => _fraunces(
        size: 22,
        weight: FontWeight.w500,
        height: 1.2,
      );

  /// Italic Fraunces — the coach's speaking voice.
  static TextStyle get coachVoice => _fraunces(
        size: 18,
        weight: FontWeight.w400,
        style: FontStyle.italic,
        height: 1.4,
        color: AppColors.inkSoft,
      );

  static TextStyle get body => _fraunces(
        size: 16,
        weight: FontWeight.w400,
        height: 1.55,
        color: AppColors.ink,
      );

  /// Used for pull-quote style moments.
  static TextStyle get quote => _fraunces(
        size: 28,
        weight: FontWeight.w500,
        style: FontStyle.italic,
        height: 1.2,
      );

  // --- UI chrome -----------------------------------------------------------

  static TextStyle get uiLabel => _plex(
        size: 13,
        weight: FontWeight.w500,
        letterSpacing: 0.15,
      );

  static TextStyle get uiBody => _plex(
        size: 14,
        weight: FontWeight.w400,
        height: 1.45,
      );

  /// Small-caps-ish section tag, e.g. "— TRAINING —".
  static TextStyle get sectionTag => _plex(
        size: 11,
        weight: FontWeight.w600,
        letterSpacing: 2.4,
        color: AppColors.oxblood,
      );

  /// A tag like "For today" on a SuggestionCard.
  static TextStyle get metaTag => _plex(
        size: 10,
        weight: FontWeight.w600,
        letterSpacing: 1.6,
        color: AppColors.oxblood,
      );

  /// Italic marginal date stamp, Fraunces italic.
  static TextStyle get editionStamp => _fraunces(
        size: 11,
        weight: FontWeight.w400,
        style: FontStyle.italic,
        letterSpacing: 0.5,
        color: AppColors.inkSoft,
      );

  // --- Numerics / tabular --------------------------------------------------

  static TextStyle get numericLarge => _mono(
        size: 18,
        weight: FontWeight.w500,
      );

  static TextStyle get numericMedium => _mono(
        size: 14,
        weight: FontWeight.w400,
      );

  static TextStyle get numericSmall => _mono(
        size: 12,
        weight: FontWeight.w400,
        color: AppColors.inkSoft,
      );
}
