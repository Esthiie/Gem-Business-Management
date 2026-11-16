import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Faith's palette (white, black, pastel purple, grey, pastel pink).
class AppColors {
  static const ink = Color(0xFF121212); // main text, main buttons
  static const muted = Color(0xFF636369); // secondary text
  static const line = Color(0xFFE5E5EA); // borders
  static const bg = Color(0xFFF7F7F8); // page background
  static const white = Color(0xFFFFFFFF);

  static const lavenderTint = Color(0xFFEDE5F8); // active nav circle, soft fills
  static const lavender = Color(0xFFCDBBEA);
  static const purple = Color(0xFF5B4691); // "Synced", New status text
  static const purpleSoft = Color(0xFFEEE8F8);
  static const purpleDot = Color(0xFF8E6CCB);

  static const pink = Color(0xFFF2B3CA);
  static const pinkText = Color(0xFFA33B68); // low stock, tips
  static const pinkSoft = Color(0xFFFCE7EF);
  static const stockPink = Color(0xFFE0789F);

  // Status colours (custom orders)
  static const orange = Color(0xFFF59E0B);
  static const orangeText = Color(0xFFB45309);
  static const orangeSoft = Color(0xFFFFEDD5);
  static const green = Color(0xFF34A853);
  static const greenText = Color(0xFF22783F);
  static const greenSoft = Color(0xFFE2F4E7);

  static const red = Color(0xFFB3261E);
  static const redBorder = Color(0xFFE7B4AE);
  static const gold = Color(0xFFE2B04A);
}

class AppText {
  /// Headings: Bricolage Grotesque.
  static TextStyle heading(double size,
          {Color color = AppColors.ink, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.getFont('Bricolage Grotesque',
          fontSize: size, fontWeight: weight, color: color, height: 1.15);

  /// Body: Plus Jakarta Sans.
  static TextStyle body(double size,
          {Color color = AppColors.ink, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size, fontWeight: weight, color: color);

  static final TextStyle label =
      body(12, color: AppColors.muted, weight: FontWeight.w700)
          .copyWith(letterSpacing: 0.4);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.purple,
        primary: AppColors.ink,
        secondary: AppColors.purple,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.bg,
    );
    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: AppText.body(15, color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: AppText.body(14, color: AppColors.white),
      ),
      dividerColor: AppColors.line,
    );
  }
}
