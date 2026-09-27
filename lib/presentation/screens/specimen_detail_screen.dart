import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/specimen.dart';
import '../../core/theme.dart';

class SpecimenDetailScreen extends StatelessWidget {
  final DesignSpecimen specimen;
  final AetherTheme theme;
  final VoidCallback onPinToggle;

  const SpecimenDetailScreen({
    super.key,
    required this.specimen,
    required this.theme,
    required this.onPinToggle,
  });

  void _showDecompressionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.borderHairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'ARTISAN ATELIER PROVENANCE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: theme.accentGlow,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Leaving the Sanctuary for ${specimen.maker}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You are being redirected to the official studio in ${specimen.studioLocation}. You will complete your order directly with the craft house.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: theme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.textPrimary,
                    foregroundColor: theme.bgPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    Navigator.of(modalContext).pop();
                    final uri = Uri.parse(specimen.provenanceUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    'VISIT OFFICIAL ATELIER STORE ➔',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.bgPrimary,
      body: CustomScrollView(
        slivers: [
          // Collapsible Monograph App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 460,
            pinned: true,
            backgroundColor: theme.bgPrimary,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    specimen.isUserPinned ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onPinToggle();
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'specimen_${specimen.id}',
                child: CachedNetworkImage(
                  imageUrl: specimen.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 1000,
                ),
              ),
            ),
          ),

          // Editorial Monograph Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Origin telemetry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${specimen.maker.toUpperCase()} • ${specimen.studioLocation.toUpperCase()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                          color: theme.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${specimen.estimatedUsd.toStringAsFixed(0)} USD',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.accentGlow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Display Title
                  Text(
                    specimen.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Materiality Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: specimen.materials.map((mat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.bgSurface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: theme.borderHairline,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          mat.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: theme.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  Divider(color: theme.borderHairline.withValues(alpha: 0.5)),
                  const SizedBox(height: 20),

                  // Material Narrative
                  Text(
                    'MATERIALITY & CRAFT STORY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    specimen.materialStory,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: theme.textPrimary.withValues(alpha: 0.9),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Acquisition Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.textPrimary,
                        foregroundColor: theme.bgPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _showDecompressionModal(context);
                      },
                      child: Text(
                        'ACQUIRE SPECIMEN ➔',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
