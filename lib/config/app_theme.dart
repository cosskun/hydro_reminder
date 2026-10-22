import 'package:flutter/material.dart';

/// Mascot-specific theme color palette definition
class MascotThemePalette {
  final String id;
  final String nameTr;
  final String nameEn;
  final String emoji;
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryDark;
  final Color scaffoldLight;
  final Color scaffoldDark;
  final Color cardLight;
  final Color cardDark;
  final Color cardBorderDark;
  final Color surfaceSubtleLight;
  final Color surfaceSubtleDark;
  final List<Color> waterGradientLight;
  final List<Color> waterGradientDark;

  const MascotThemePalette({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.emoji,
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryDark,
    required this.scaffoldLight,
    required this.scaffoldDark,
    required this.cardLight,
    required this.cardDark,
    required this.cardBorderDark,
    required this.surfaceSubtleLight,
    required this.surfaceSubtleDark,
    required this.waterGradientLight,
    required this.waterGradientDark,
  });
}

class AppTheme {
  // Palettes for all 5 animal mascots + original ocean default
  static const Map<String, MascotThemePalette> palettes = {
    'ocean': MascotThemePalette(
      id: 'ocean',
      nameTr: 'Okyanus Mavisi (Orijinal)',
      nameEn: 'Ocean Blue (Original)',
      emoji: '💧',
      primary: Color(0xFF0288D1),
      primaryDark: Color(0xFF38BDF8),
      secondary: Color(0xFF26C6DA),
      secondaryDark: Color(0xFF00E5FF),
      scaffoldLight: Color(0xFFF4F9FD),
      scaffoldDark: Color(0xFF0B132B),
      cardLight: Colors.white,
      cardDark: Color(0xFF1C2541),
      cardBorderDark: Color(0xFF3A506B),
      surfaceSubtleLight: Color(0xFFEFF6FF),
      surfaceSubtleDark: Color(0xFF1E293B),
      waterGradientLight: [Color(0xFF0288D1), Color(0xFF26C6DA)],
      waterGradientDark: [Color(0xFF0369A1), Color(0xFF38BDF8)],
    ),
    'cat': MascotThemePalette(
      id: 'cat',
      nameTr: 'Gece Leylağı (Luna)',
      nameEn: 'Night Lavender (Luna)',
      emoji: '🐱',
      primary: Color(0xFF7C3AED),
      primaryDark: Color(0xFFA78BFA),
      secondary: Color(0xFFEC4899),
      secondaryDark: Color(0xFFF472B6),
      scaffoldLight: Color(0xFFF8F5FF),
      scaffoldDark: Color(0xFF0F0B1E),
      cardLight: Colors.white,
      cardDark: Color(0xFF1A1433),
      cardBorderDark: Color(0xFF3B2F66),
      surfaceSubtleLight: Color(0xFFF3E8FF),
      surfaceSubtleDark: Color(0xFF261D47),
      waterGradientLight: [Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFEC4899)],
      waterGradientDark: [Color(0xFF5B21B6), Color(0xFFA78BFA)],
    ),
    'dog': MascotThemePalette(
      id: 'dog',
      nameTr: 'Sıcak Karamel (Buddy)',
      nameEn: 'Warm Caramel (Buddy)',
      emoji: '🐩',
      primary: Color(0xFFD97706),
      primaryDark: Color(0xFFFBBF24),
      secondary: Color(0xFFEA580C),
      secondaryDark: Color(0xFFFB923C),
      scaffoldLight: Color(0xFFFFFBF5),
      scaffoldDark: Color(0xFF17110A),
      cardLight: Colors.white,
      cardDark: Color(0xFF261B0E),
      cardBorderDark: Color(0xFF4D381B),
      surfaceSubtleLight: Color(0xFFFEF3C7),
      surfaceSubtleDark: Color(0xFF3B2A15),
      waterGradientLight: [Color(0xFFD97706), Color(0xFFF59E0B)],
      waterGradientDark: [Color(0xFFB45309), Color(0xFFFBBF24)],
    ),
    'penguin': MascotThemePalette(
      id: 'penguin',
      nameTr: 'Buzul Kristali (Pip)',
      nameEn: 'Glacier Ice (Pip)',
      emoji: '🐧',
      primary: Color(0xFF0284C7),
      primaryDark: Color(0xFF38BDF8),
      secondary: Color(0xFF0D9488),
      secondaryDark: Color(0xFF2DD4BF),
      scaffoldLight: Color(0xFFF0FDFA),
      scaffoldDark: Color(0xFF051724),
      cardLight: Colors.white,
      cardDark: Color(0xFF0C273D),
      cardBorderDark: Color(0xFF194668),
      surfaceSubtleLight: Color(0xFFCCFBF1),
      surfaceSubtleDark: Color(0xFF103652),
      waterGradientLight: [Color(0xFF0284C7), Color(0xFF14B8A6)],
      waterGradientDark: [Color(0xFF0369A1), Color(0xFF2DD4BF)],
    ),
    'panda': MascotThemePalette(
      id: 'panda',
      nameTr: 'Zen Bambu (Bobo)',
      nameEn: 'Zen Bamboo (Bobo)',
      emoji: '🐼',
      primary: Color(0xFF059669),
      primaryDark: Color(0xFF34D399),
      secondary: Color(0xFF65A30D),
      secondaryDark: Color(0xFFA3E635),
      scaffoldLight: Color(0xFFF0FDF4),
      scaffoldDark: Color(0xFF06180F),
      cardLight: Colors.white,
      cardDark: Color(0xFF0E2E1D),
      cardBorderDark: Color(0xFF1D5235),
      surfaceSubtleLight: Color(0xFFDCFCE7),
      surfaceSubtleDark: Color(0xFF14422A),
      waterGradientLight: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF84CC16)],
      waterGradientDark: [Color(0xFF047857), Color(0xFF34D399)],
    ),
    'squirrel': MascotThemePalette(
      id: 'squirrel',
      nameTr: 'Sonbahar Amberi (Fındık)',
      nameEn: 'Autumn Amber (Nutty)',
      emoji: '🐿️',
      primary: Color(0xFFEA580C),
      primaryDark: Color(0xFFFB923C),
      secondary: Color(0xFFD97706),
      secondaryDark: Color(0xFFFBBF24),
      scaffoldLight: Color(0xFFFFF7ED),
      scaffoldDark: Color(0xFF1C0D05),
      cardLight: Colors.white,
      cardDark: Color(0xFF2C160B),
      cardBorderDark: Color(0xFF572C15),
      surfaceSubtleLight: Color(0xFFFFEDD5),
      surfaceSubtleDark: Color(0xFF3D1F0E),
      waterGradientLight: [Color(0xFFEA580C), Color(0xFFF97316)],
      waterGradientDark: [Color(0xFFC2410C), Color(0xFFFB923C)],
    ),
  };

  /// Returns the palette for a given preset ID, falling back to 'ocean'
  static MascotThemePalette getPalette(String presetId) {
    return palettes[presetId] ?? palettes['ocean']!;
  }

  /// Builds a ThemeData configured for the given mascot/theme preset and brightness
  static ThemeData getTheme(String presetId, {required bool isDark}) {
    final palette = getPalette(presetId);
    final primaryColor = isDark ? palette.primaryDark : palette.primary;
    final secondaryColor = isDark ? palette.secondaryDark : palette.secondary;
    final scaffoldBg = isDark ? palette.scaffoldDark : palette.scaffoldLight;
    final cardBg = isDark ? palette.cardDark : palette.cardLight;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryColor,
              onPrimary: palette.scaffoldDark,
              secondary: secondaryColor,
              onSecondary: palette.scaffoldDark,
              surface: cardBg,
              onSurface: const Color(0xFFF1F5F9),
              error: const Color(0xFFEF4444),
              onError: Colors.white,
            )
          : ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              secondary: secondaryColor,
              onSecondary: Colors.white,
              surface: cardBg,
              onSurface: const Color(0xFF1E293B),
              error: const Color(0xFFE53935),
              onError: Colors.white,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardBg,
        foregroundColor: primaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 3 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? BorderSide(color: palette.cardBorderDark, width: 1)
              : BorderSide.none,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
      ),
      fontFamily: 'Roboto',
    );
  }

  /// Default Light and Dark themes for backward compatibility
  static ThemeData get lightTheme => getTheme('ocean', isDark: false);
  static ThemeData get darkTheme => getTheme('ocean', isDark: true);
}
