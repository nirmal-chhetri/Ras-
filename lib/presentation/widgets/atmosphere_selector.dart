import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/specimen.dart';
import '../../core/theme.dart';

/// ============================================================================
/// FILE: lib/presentation/widgets/atmosphere_selector.dart
/// ARCHITECTURE LAYER: Presentation UI Widget (Phase 3)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// [AtmosphereSelector] renders the tactile top-bar capsule that allows users
/// to manually transition between atmospheric biomes:
/// - Rain & Study (Slate Charcoal)
/// - Raw Terracotta (Warm Travertine)
///
/// DESIGN & INTERACTION:
/// - Shows active atmosphere state with an accent dot indicator and dropdown chevron.
/// - Opens a floating popup menu styled with the active theme's surface color and
///   hairline borders.
/// - Displays both the uppercase biome name (in Plus Jakarta Sans) and the
///   acoustic frequency telemetry (in Space Grotesk).
/// - Triggers tactile haptic feedback ([HapticFeedback.selectionClick]) on selection.
/// ============================================================================

/// Broadsheet top-bar widget for inspecting and selecting the active atmosphere biome.
class AtmosphereSelector extends StatelessWidget {
  /// The list of available atmospheres from the catalog.
  final List<Atmosphere> atmospheres;

  /// Identifier of the currently active atmosphere.
  final String activeId;

  /// Current visual theme tokens for coloring the selector and popup.
  final AetherTheme theme;

  /// Callback invoked when the user selects a new atmosphere.
  final ValueChanged<String> onAtmosphereSelected;

  const AtmosphereSelector({
    super.key,
    required this.atmospheres,
    required this.activeId,
    required this.theme,
    required this.onAtmosphereSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve active atmosphere metadata safely
    final active = atmospheres.firstWhere(
      (a) => a.id == activeId,
      orElse: () => atmospheres.first,
    );

    return PopupMenuButton<String>(
      onSelected: (newId) {
        HapticFeedback.selectionClick();
        onAtmosphereSelected(newId);
      },
      color: theme.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: theme.borderHairline.withValues(alpha: 0.8),
          width: 1.0,
        ),
      ),
      elevation: 12,
      offset: const Offset(0, 36),
      itemBuilder: (context) {
        return atmospheres.map((atmos) {
          final isSelected = atmos.id == activeId;
          return PopupMenuItem<String>(
            value: atmos.id,
            height: 48,
            child: Row(
              children: [
                // Radio status ring with accent fill
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? theme.accentGlow : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? theme.accentGlow
                          : theme.textSecondary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Atmospheric Name
                      Text(
                        atmos.displayName.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 1.1,
                          color: isSelected
                              ? theme.textPrimary
                              : theme.textSecondary,
                        ),
                      ),
                      // Acoustic Frequency Telemetry
                      Text(
                        atmos.telemetryFrequency,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          color: theme.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.borderHairline.withValues(alpha: 0.7),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active atmosphere pulsating dot
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentGlow,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ATMOSPHERE: ${active.displayName.toUpperCase()}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: theme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
