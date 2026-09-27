import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/specimen.dart';
import '../../core/theme.dart';
import '../../core/gateways/provenance_gateway.dart';

class SpecimenDetailScreen extends StatefulWidget {
  final DesignSpecimen specimen;
  final AetherTheme theme;
  final VoidCallback onPinToggle;
  final IProvenanceGateway? provenanceGateway;

  const SpecimenDetailScreen({
    super.key,
    required this.specimen,
    required this.theme,
    required this.onPinToggle,
    this.provenanceGateway,
  });

  @override
  State<SpecimenDetailScreen> createState() => _SpecimenDetailScreenState();
}

class _SpecimenDetailScreenState extends State<SpecimenDetailScreen> {
  late bool _isPinned;
  late final IProvenanceGateway _provenanceGateway;

  @override
  void initState() {
    super.initState();
    _isPinned = widget.specimen.isUserPinned;
    _provenanceGateway = widget.provenanceGateway ?? UrlLauncherProvenanceGateway();
  }

  void _handlePinToggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPinned = !_isPinned;
    });
    widget.onPinToggle();
  }

  void _showDecompressionModal(BuildContext context) {
    final theme = widget.theme;
    final specimen = widget.specimen;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.bgSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(modalContext).viewInsets.bottom + 36,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle pill
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

              // Provenance telemetry header
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.accentGlow,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SLOW-COMMERCE DECOMPRESSION GATE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: theme.accentGlow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                'Leaving Sanctuary for ${specimen.maker}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),

              // Philosophical slow-commerce narrative
              Text(
                'Aether connects you directly to the artisan atelier in ${specimen.studioLocation}. '
                'In the spirit of mindful living, we encourage deliberate curation over impulse consumption. '
                'You will complete your acquisition directly with the craft house without intermediary markups.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: theme.textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),

              // Direct link badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.bgPrimary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.borderHairline.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 14, color: theme.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        specimen.provenanceUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action button
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
                    final canLaunch = await _provenanceGateway.canLaunchArtisanStore(specimen.provenanceUrl);
                    if (canLaunch) {
                      await _provenanceGateway.launchArtisanStore(specimen.provenanceUrl);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Unable to open external store link: ${specimen.provenanceUrl}',
                              style: TextStyle(color: theme.textPrimary),
                            ),
                            backgroundColor: theme.bgSurface,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'PROCEED WITH MINDFUL INTENT ➔',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
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
    final theme = widget.theme;
    final specimen = widget.specimen;

    return Scaffold(
      backgroundColor: theme.bgPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Full-Bleed Hero App Bar
          SliverAppBar(
            expandedHeight: 480,
            pinned: true,
            backgroundColor: theme.bgPrimary,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _isPinned
                        ? theme.accentGlow
                        : Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPinned ? Icons.bookmark : Icons.bookmark_border,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                onPressed: _handlePinToggle,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'specimen_${specimen.id}',
                    child: CachedNetworkImage(
                      imageUrl: specimen.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 1000,
                    ),
                  ),
                  // Subtle bottom vignette gradient
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            theme.bgPrimary.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Editorial Monograph Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Origin telemetry & Estimated Value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${specimen.maker.toUpperCase()} • ${specimen.studioLocation.toUpperCase()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                            color: theme.textSecondary,
                          ),
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
                  const SizedBox(height: 10),

                  // Display Title
                  Text(
                    specimen.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 29,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                      height: 1.18,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 24),

                  Divider(color: theme.borderHairline.withValues(alpha: 0.5)),
                  const SizedBox(height: 20),

                  // Material Narrative & Craft Story
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
                      color: theme.textPrimary.withValues(alpha: 0.92),
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Atmospheric Resonance Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.bgSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.borderHairline.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.graphic_eq_rounded,
                          size: 16,
                          color: theme.accentGlow,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ATMOSPHERIC RESONANCE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: theme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                specimen.atmosphereTag.replaceAll('_', ' ').toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                          borderRadius: BorderRadius.circular(8),
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
                          fontSize: 12.0,
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
