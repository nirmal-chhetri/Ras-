import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AetherTheme {
  final String id;
  final String name;
  final Color bgPrimary;
  final Color bgSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderHairline;
  final Color accentGlow;
  final Brightness brightness;

  const AetherTheme({
    required this.id,
    required this.name,
    required this.bgPrimary,
    required this.bgSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderHairline,
    required this.accentGlow,
    required this.brightness,
  });

  // 1. Rain & Study (Slate Charcoal)
  static const slateCharcoal = AetherTheme(
    id: 'rain_study',
    name: 'Rain & Study',
    bgPrimary: Color(0xFF16181D),
    bgSurface: Color(0xFF1E2128),
    textPrimary: Color(0xFFF0F2F5),
    textSecondary: Color(0xFF8C93A0),
    borderHairline: Color(0xFF2A2E38),
    accentGlow: Color(0xFF5E81AC),
    brightness: Brightness.dark,
  );

  // 2. Tokyo Nocturne (Obsidian Neon)
  static const obsidianNeon = AetherTheme(
    id: 'tokyo_nocturne',
    name: 'Tokyo Nocturne',
    bgPrimary: Color(0xFF0B0C10),
    bgSurface: Color(0xFF14161E),
    textPrimary: Color(0xFFEAEAEA),
    textSecondary: Color(0xFF6B7280),
    borderHairline: Color(0xFF1F2330),
    accentGlow: Color(0xFF3D5AFE),
    brightness: Brightness.dark,
  );

  // 3. Raw Terracotta (Warm Travertine)
  static const warmTravertine = AetherTheme(
    id: 'raw_terracotta',
    name: 'Raw Terracotta',
    bgPrimary: Color(0xFFF5F2EB),
    bgSurface: Color(0xFFECE7DD),
    textPrimary: Color(0xFF2A221E),
    textSecondary: Color(0xFF7C726B),
    borderHairline: Color(0xFFDDD6C8),
    accentGlow: Color(0xFFC86432),
    brightness: Brightness.light,
  );

  static AetherTheme fromAtmosphereId(String id) {
    switch (id) {
      case 'tokyo_nocturne':
        return obsidianNeon;
      case 'raw_terracotta':
        return warmTravertine;
      case 'rain_study':
      default:
        return slateCharcoal;
    }
  }

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgPrimary,
      cardColor: bgSurface,
      dividerColor: borderHairline,
      textTheme: TextTheme(
        // Editorial Serif for headers
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
          color: textPrimary,
        ),
        // Functional Grotesque for UI & descriptions
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),
        // Uppercase labels
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 1.2,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
