import 'package:flutter/material.dart';

enum AppThemeType { bruno, patel }

class AppTheme {
  final AppThemeType type;
  final Color primary;
  final Color background; // Unified background
  final Color surface; // Unified surface (card color)
  final Color woodAccent; // Accent/Border
  final Color woodDark; // New: Darker wood for containers
  final Color woodLight; // New: Lighter wood for text/accents
  final Color textPrimary;
  final Color textSecondary;
  final Brightness brightness;

  const AppTheme({
    required this.type,
    required this.primary,
    required this.background,
    required this.surface,
    required this.woodAccent,
    required this.woodDark,
    required this.woodLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.brightness,
  });

  // Bruno Theme: Dark, Earthy, Wood
  factory AppTheme.bruno() {
    return const AppTheme(
      type: AppThemeType.bruno,
      primary: Color(0xFFD47311),
      background: Color(0xFF221910),
      surface: Color(0xFF2C241B),
      woodAccent: Color(0xFF483623),
      woodDark: Color(0xFF1A120B),
      woodLight: Color(0xFF3E2B1D),
      textPrimary: Colors.white,
      textSecondary: Color(0xFFC9AD92),
      brightness: Brightness.dark,
    );
  }

  // Patel Theme: Light, Pastel, Soft
  factory AppTheme.patel() {
    return const AppTheme(
      type: AppThemeType.patel,
      primary: Color(0xFF8EC5FC), // Pastel Blue
      background: Color(0xFFF8F9FA), // Off-white
      surface: Colors.white,
      woodAccent: Color(0xFFE2E8F0), // Light Gray
      woodDark: Color(
        0xFFE2E8F0,
      ), // Light Gray (reused for lack of wood concept)
      woodLight: Color(0xFFF1F5F9), // Slate 100
      textPrimary: Color(0xFF1E293B), // Slate 800
      textSecondary: Color(0xFF64748B), // Slate 500
      brightness: Brightness.light,
    );
  }

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        surface: surface,
        onSurface: textPrimary,
        background: background,
        onBackground: textPrimary,
      ),
      extensions: [
        AppThemeExtension(
          woodAccent: woodAccent,
          woodDark: woodDark,
          woodLight: woodLight,
          surface: surface,
          textSecondary: textSecondary,
        ),
      ],
      // Typography overrides if needed
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: textPrimary),
        titleMedium: TextStyle(color: textPrimary),
      ),
    );
  }
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color woodAccent;
  final Color woodDark;
  final Color woodLight;
  final Color surface; // Replaces surfaceDark distinction
  final Color textSecondary;

  AppThemeExtension({
    required this.woodAccent,
    required this.woodDark,
    required this.woodLight,
    required this.surface,
    required this.textSecondary,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? woodAccent,
    Color? woodDark,
    Color? woodLight,
    Color? surface,
    Color? textSecondary,
  }) {
    return AppThemeExtension(
      woodAccent: woodAccent ?? this.woodAccent,
      woodDark: woodDark ?? this.woodDark,
      woodLight: woodLight ?? this.woodLight,
      surface: surface ?? this.surface,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      woodAccent: Color.lerp(woodAccent, other.woodAccent, t)!,
      woodDark: Color.lerp(woodDark, other.woodDark, t)!,
      woodLight: Color.lerp(woodLight, other.woodLight, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}
