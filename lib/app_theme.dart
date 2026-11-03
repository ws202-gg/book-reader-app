import 'package:flutter/material.dart';

class AppPalette {
  static const terracotta = Color(0xFFB84F31);
  static const terracottaDark = Color(0xFF8F3C27);
  static const cream = Color(0xFFFAF6F0);
  static const ink = Color(0xFF28221F);
  static const muted = Color(0xFF837A74);
  static const line = Color(0xFFE9E1D8);
  static const darkBackground = Color(0xFF171513);
  static const darkSurface = Color(0xFF24211E);
}

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.terracotta,
    brightness: brightness,
    surface: dark ? AppPalette.darkSurface : Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: dark
        ? AppPalette.darkBackground
        : AppPalette.cream,
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? AppPalette.darkBackground : AppPalette.cream,
      foregroundColor: dark ? Colors.white : AppPalette.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: dark ? Colors.white : AppPalette.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: dark ? AppPalette.darkSurface : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? AppPalette.darkSurface : Colors.white,
      hintStyle: const TextStyle(color: AppPalette.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: dark ? Colors.white12 : AppPalette.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: dark ? Colors.white12 : AppPalette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.terracotta, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? AppPalette.darkSurface : Colors.white,
      indicatorColor: AppPalette.terracotta.withValues(alpha: .12),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
