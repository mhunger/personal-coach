import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: AppColors.oxblood,
        onPrimary: AppColors.paper,
        secondary: AppColors.sage,
        onSecondary: AppColors.ink,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
        surfaceTint: Colors.transparent,
        outline: AppColors.ruleGray,
        error: AppColors.oxblood,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        displayMedium: AppTypography.title,
        headlineSmall: AppTypography.headline,
        titleLarge: AppTypography.headline,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.body,
        labelLarge: AppTypography.uiLabel,
        labelMedium: AppTypography.uiLabel,
        labelSmall: AppTypography.sectionTag,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.ruleGray,
        thickness: 1,
        space: 24,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.oxblood,
          foregroundColor: AppColors.paper,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTypography.uiLabel.copyWith(
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.oxblood,
          textStyle: AppTypography.uiLabel.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        hintStyle: AppTypography.body.copyWith(color: AppColors.ruleGrayStrong),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.ruleGray, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.oxblood, width: 1.5),
        ),
      ),
    );
  }
}
