import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F9FD),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0288D1),
      onPrimary: Colors.white,
      secondary: Color(0xFF26C6DA),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1E293B),
      error: Color(0xFFE53935),
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF0288D1),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF0288D1),
      unselectedItemColor: Color(0xFF94A3B8),
      elevation: 8,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    fontFamily: 'Roboto',
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B132B), // Deep Midnight Blue
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF38BDF8),
      onPrimary: Color(0xFF0B132B),
      secondary: Color(0xFF00E5FF),
      onSecondary: Color(0xFF0B132B),
      surface: Color(0xFF1C2541),
      onSurface: Color(0xFFF1F5F9),
      error: Color(0xFFEF4444),
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C2541),
      foregroundColor: Color(0xFF38BDF8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1C2541),
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF3A506B), width: 1),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1C2541),
      selectedItemColor: Color(0xFF38BDF8),
      unselectedItemColor: Color(0xFF64748B),
      elevation: 8,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF1C2541),
      surfaceTintColor: Colors.transparent,
    ),
    fontFamily: 'Roboto',
  );
}
