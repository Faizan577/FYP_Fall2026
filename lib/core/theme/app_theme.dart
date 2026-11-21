import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand Palette from Figma Design System
  static const primary = Color(0xFF245C43); // Primary Green
  static const secondary = Color(0xFF397A55); // Secondary Green
  static const sage = Color(0xFFA8BDA5); // Sage
  static const sageLight = Color(0xFFE4ECE1); // Sage Light / Accent
  static const cream = Color(0xFFF7F6EF); // Cream Background
  static const white = Color(0xFFFFFFFF); // White Surface
  static const dark = Color(0xFF26352C); // Dark Text / Ink
  static const muted = Color(0xFF6B7A70); // Muted Text
  static const soft = Color(0xFFE4EFE6); // Soft Green
  static const border = Color(0xFFE3E7DA); // Soft Border
  static const borderLight = Color(0xFFE3E8E0);

  // Section Color Accents & Tints from Figma
  static const farmAccent = Color(0xFF7A5F14);
  static const farmTint = Color(0xFFEFE6C8);

  static const gardenAccent = Color(0xFFA4505C);
  static const gardenTint = Color(0xFFF6E1E3);

  static const nurseryAccent = Color(0xFF245C43);
  static const nurseryTint = Color(0xFFE4ECE1);

  static const communityAccent = Color(0xFF8F5F32);
  static const communityTint = Color(0xFFF3E4D3);

  // Compatibility aliases
  static const forest = primary;
  static const leaf = secondary;
  static const surface = white;
  static const ink = dark;
  static const line = border;
  static const lime = sage;
  static const peach = communityTint;
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.white,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.dark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.dark,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}
