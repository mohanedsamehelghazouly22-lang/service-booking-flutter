import 'package:flutter/material.dart';

/// Visual language pulled from the reference UI:
/// warm peach/orange background, dark near-black rounded cards,
/// orange primary actions, compact rounded bottom nav.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF6E4D4); // warm peach
  static const Color backgroundAlt = Color(0xFFF0D8C2);
  static const Color card = Color(0xFF1C1B1A); // near-black card
  static const Color cardAlt = Color(0xFF2A2826);
  static const Color primary = Color(0xFFE8712A); // orange primary action
  static const Color primaryDark = Color(0xFFC85A1C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1C1B1A);
  static const Color textOnCard = Color(0xFFFFFFFF);
  static const Color textMutedOnCard = Color(0xFFB8B4AF);
  static const Color textMuted = Color(0xFF6F6A63);
  static const Color success = Color(0xFF3FA65B);
  static const Color warning = Color(0xFFE0A72E);
  static const Color danger = Color(0xFFD9483B);
  static const Color chipBg = Color(0xFFEAD3BD);
}

class AppRadii {
  AppRadii._();
  static const double card = 28;
  static const double tile = 22;
  static const double button = 18;
  static const double chip = 14;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 26,
          color: AppColors.textDark,
          letterSpacing: -0.5,
        ),
        titleLarge: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.textDark,
        ),
        titleMedium: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.textDark,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: AppColors.textMuted,
          height: 1.4,
        ),
        labelLarge: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.textDark, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMutedOnCard,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.chipBg,
        labelStyle: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.chip)),
        side: BorderSide.none,
      ),
    );
  }
}
