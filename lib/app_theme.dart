import 'package:flutter/material.dart';

class AppPalette {
  static const Color archiveBackground = Color(0xFF1B1714);
  static const Color archiveSurface = Color(0xFF30251D);
  static const Color parchment = Color(0xFFF2E6C9);
  static const Color ink = Color(0xFF2B2118);
  static const Color amber = Color(0xFFC47A1B);
  static const Color mossGreen = Color(0xFF4E7D4A);
  static const Color brickRed = Color(0xFFA63D32);
  static const Color mutedBrown = Color(0xFF6C5140);
  static const Color karelianPanel = Color(0xFFF3E3B2);
  static const Color translationPanel = Color(0xFFE8D3A0);
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.amber,
    brightness: Brightness.light,
    primary: AppPalette.mutedBrown,
    onPrimary: AppPalette.parchment,
    surface: AppPalette.parchment,
    onSurface: AppPalette.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppPalette.parchment,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.archiveSurface,
      foregroundColor: AppPalette.parchment,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Centro',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: AppPalette.parchment,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.mutedBrown,
        foregroundColor: AppPalette.parchment,
        textStyle: const TextStyle(
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppPalette.parchment,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppPalette.amber, width: 1.2),
      ),
    ),
  );
}
