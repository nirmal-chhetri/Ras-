import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/specimen.dart';
import '../../core/theme.dart';

class AtmosphereSelector extends StatelessWidget {
  final List<Atmosphere> atmospheres;
  final String activeId;
  final AetherTheme theme;
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
                      Text(
                        atmos.displayName.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 1.1,
                          color: isSelected ? theme.textPrimary : theme.textSecondary,
                        ),
                      ),
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
