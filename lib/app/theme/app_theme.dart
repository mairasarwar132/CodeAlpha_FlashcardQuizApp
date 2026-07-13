import 'package:codealpha_flashcard_quiz_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    );

    return _theme(
      colorScheme,
    ).copyWith(scaffoldBackgroundColor: AppColors.lightScaffold);
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkSeed,
      brightness: Brightness.dark,
    );

    return _theme(
      colorScheme,
    ).copyWith(scaffoldBackgroundColor: AppColors.darkScaffold);
  }

  static ThemeData _theme(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
    );
  }
}
