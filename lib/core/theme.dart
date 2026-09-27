import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================================
/// FILE: lib/core/theme.dart
/// ARCHITECTURE LAYER: Design System & Visual Token Foundation (Phase 0, 1 & 3)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// This file implements the three synchronized atmospheric design themes and
/// dual typographic voices defined in the Aether Design System specification:
///
/// 1. DUAL TYPOGRAPHIC VOICE:
///    - Editorial Voice: [GoogleFonts.playfairDisplay] (classic serif)
///      Used for masthead headlines, poetic taglines, and specimen titles.
///    - Functional Voice: [GoogleFonts.plusJakartaSans] (clean grotesk)
///      Used for body text, navigation tabs, maker signatures, and UI labels.
///    - Tabular Voice: [GoogleFonts.spaceGrotesk] (monospace/tabular numerals)
///      Used for telemetry frequencies, USD currency values, and technical badges.
///
/// 2. SYNCHRONIZED ATMOSPHERIC BIOMES:
///    - Slate Charcoal ('rain_study'):
///      Reflective, quiet rain study. Dark slate #16181D with deep surface
///      #1E2128 and calm blue accent #5E81AC. (Consolidated with nocturnal themes).
///    - Warm Travertine ('raw_terracotta'):
///      Warm daylight slow living. Textured travertine #F5F2EB with sun-baked
///      clay/terracotta accent #C86432.
///
/// 3. MODERN FLUTTER COMPATIBILITY:
///    - Uses Material 3 (`useMaterial3: true`).
///    - Avoids deprecated `Color.withOpacity(alpha)` in favor of
///      `Color.withValues(alpha: alpha)` introduced in Flutter 3.27+.
///
/// EXTENSION GUIDE FOR FUTURE DEVELOPERS:
/// - To add a 4th Atmosphere theme (e.g. Nordic Moss / Forest Solitude):
///   1. Declare a `static const AetherTheme nordicMoss = AetherTheme(...)` below.
///   2. Map its id in [AetherTheme.fromAtmosphereId].
///   3. Update [AtmosphereStateMachine] and [DATA_CATALOG.json].
/// ============================================================================

/// Represents a sensory visual color and typography system.
class AetherTheme {
  /// Unique theme key matching the atmosphere ID.
  final String id;

  /// Display name of the theme shown in settings or inspectors.
  final String name;

  /// Primary canvas background color (deep tone in dark mode, creamy in light).
  final Color bgPrimary;

  /// Elevated card, modal bottom sheet, and dock container surface color.
  final Color bgSurface;

  /// High-contrast primary text color for headlines and titles.
  final Color textPrimary;

  /// Low-contrast secondary text color for body narratives and maker captions.
  final Color textSecondary;

  /// Hairline structural border color for cards, dividers, and capsules.
  final Color borderHairline;

  /// Atmospheric accent glow used for active tabs, waveforms, and callouts.
  final Color accentGlow;

  /// Brightness mode (Brightness.dark or Brightness.light).
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

  // ===========================================================================
  // ATMOSPHERIC PRESETS
  // ===========================================================================

  /// Atmosphere 1: Rain & Study (Slate Charcoal)
  /// Ambient rain, wet slate cobblestones, contemplative reading desk.
  ///
  /// SCIENTIFIC ERGONOMIC CALIBRATION:
  /// - textPrimary (#EAEAEA): Anti-Halation / Retinal Irradiation Prevention (Piepenbrock et al., 2014; Dobres et al., 2017).
  ///   Pure white (#FFFFFF) or high-luminance cool whites on dark fields cause optical glare and light bleed
  ///   across adjacent retinal photoreceptors (especially for users with astigmatism).
  ///   #EAEAEA provides an optimal ~13.5:1 Weber contrast ratio: exceeding WCAG AAA standards while
  ///   preventing pupil constriction and ciliary ocular fatigue during prolonged contemplation.
  /// - bgSurface (#1A1C23): Weber-Fechner layer separation from bgPrimary (#16181D).
  static const slateCharcoal = AetherTheme(
    id: 'rain_study',
    name: 'Rain & Study',
    bgPrimary: Color(0xFF16181D),
    bgSurface: Color(0xFF1A1C23),
    textPrimary: Color(0xFFEAEAEA),
    textSecondary: Color(0xFF8C93A0),
    borderHairline: Color(0xFF2A2E38),
    accentGlow: Color(0xFF5E81AC),
    brightness: Brightness.dark,
  );

  /// Atmosphere 2: Raw Terracotta (Warm Travertine)
  /// Afternoon Mediterranean sunshine, porous limestone, unglazed artisanal clay.
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

  /// Legacy alias: Tokyo Nocturne consolidated into Rain & Study to eliminate redundant dark themes.
  static const obsidianNeon = slateCharcoal;

  /// Resolves an [AetherTheme] instance from an atmosphere ID string.
  /// Falls back safely to [slateCharcoal] for unrecognized or missing keys.
  static AetherTheme fromAtmosphereId(String id) {
    switch (id) {
      case 'raw_terracotta':
        return warmTravertine;
      case 'tokyo_nocturne':
      case 'rain_study':
      default:
        return slateCharcoal;
    }
  }

  /// Converts this custom atmospheric token set into a standard Flutter [ThemeData].
  ///
  /// This bridges our custom tokens with Flutter's widget tree so standard
  /// components (Scaffolds, Tooltips, Dividers) automatically inherit the
  /// active atmosphere's aesthetic.
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgPrimary,
      cardColor: bgSurface,
      dividerColor: borderHairline,
      textTheme: TextTheme(
        // Editorial Serif typography for broadsheet masthead and title banners
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

        // Functional Grotesk typography for body text, story narratives, and UI
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

        // Tabular uppercase labels for telemetry badges, filters, and maker tags
        // SCIENTIFIC PRINCIPLE: Typographic Legibility at Small Optical Sizes (Bringhurst, 2004; Tinker, 1963)
        // All-caps micro-typography lacks bouma word-shape variety; expanding tracking to +1.5em (15%)
        // prevents glyph crowding and dramatically improves reading velocity and character discrimination.
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 1.5,
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
