import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/specimen.dart';
import '../../core/theme.dart';
import '../../core/audio_controller.dart';
import '../screens/specimen_detail_screen.dart';

/// ============================================================================
/// FILE: lib/presentation/widgets/specimen_card.dart
/// ARCHITECTURE LAYER: Presentation UI Widget (Phase 3)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// [SpecimenCard] represents a single artisanal artifact within the 2-column
/// staggered masonry feed.
///
/// DESIGN & BEHAVIORAL DETAILS:
/// 1. Staggered Entrance Animation:
///    Uses [TweenAnimationBuilder] staggered by the card's index in the grid
///    (`Duration(milliseconds: 300 + (index % 6) * 60)`). Each card slides
///    upwards 16px and fades from 0.0 to 1.0 opacity on first mount.
///
/// 2. Deterministic Aspect Ratio Clamping:
///    Wraps the image in an [AspectRatio] widget using `specimen.aspectRatio`,
///    which has been pre-verified by [AspectRatioVerifier] to be in [0.75, 1.33].
///    This guarantees no layout shifts, overflow, or jumpy rendering.
///
/// 3. Hero Visual Continuity:
///    The photographic canvas is tagged with `'specimen_${specimen.id}'`, creating
///    a seamless full-bleed Hero expansion when navigating into [SpecimenDetailScreen].
///
/// 4. Tactile Bookmark Pin:
///    A floating circular bookmark button in the upper-right corner allows
///    instant one-tap curation to the user's Studio. Provides medium haptic feedback.
///
/// 5. Desktop/Web Hover State:
///    [MouseRegion] listens for pointer hover to elevate shadows and accent
///    the hairline border with [theme.accentGlow].
///
/// 6. Broadsheet Typography:
///    - Maker: All-caps Plus Jakarta Sans, 9.0pt, letter-spacing 1.1.
///    - Price: Space Grotesk, 10.5pt, bold tabular numerals.
///    - Title: Playfair Display, 13.5pt, semi-bold editorial serif.
/// ============================================================================

/// Masonry grid card displaying an artisanal design specimen.
class SpecimenCard extends StatefulWidget {
  /// The domain specimen data model.
  final DesignSpecimen specimen;

  /// Current visual theme tokens.
  final AetherTheme theme;

  /// Callback executed when the bookmark pin is tapped.
  final VoidCallback onPinToggle;

  /// Position index in the masonry grid, used to stagger entrance animations.
  final int index;

  /// Optional ambient audio controller forwarded to the detail monograph for ducking.
  final AudioEngineController? audioController;

  const SpecimenCard({
    super.key,
    required this.specimen,
    required this.theme,
    required this.onPinToggle,
    this.index = 0,
    this.audioController,
  });

  @override
  State<SpecimenCard> createState() => _SpecimenCardState();
}

class _SpecimenCardState extends State<SpecimenCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final specimen = widget.specimen;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (widget.index % 6) * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 350),
                reverseTransitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SpecimenDetailScreen(
                      specimen: specimen,
                      theme: theme,
                      onPinToggle: widget.onPinToggle,
                      audioController: widget.audioController,
                    ),
                  );
                },
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: theme.bgSurface,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _isHovered
                    ? theme.accentGlow.withValues(alpha: 0.6)
                    : theme.borderHairline.withValues(alpha: 0.7),
                width: _isHovered ? 1.2 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: _isHovered ? 0.18 : 0.06),
                  // Visual depth cue (Gibson's Ecological Affordance, 1979):
                  // Increased blur (20px) and vertical translation (8px) simulate real-world
                  // physical elevation above the canvas surface, signalling tactile interactability.
                  blurRadius: _isHovered ? 20 : 8,
                  offset: Offset(0, _isHovered ? 8 : 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Clamped Photographic Canvas with Hero Transition
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: specimen.aspectRatio,
                      child: Hero(
                        tag: 'specimen_${specimen.id}',
                        child: CachedNetworkImage(
                          imageUrl: specimen.imageUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                          placeholder: (context, url) => Container(
                            color: theme.bgSurface,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: theme.textSecondary
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.bgSurface,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 24,
                                color: theme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Top-right Tactile Bookmark Pin Icon
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onPinToggle();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: specimen.isUserPinned
                                ? theme.accentGlow
                                : Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            specimen.isUserPinned
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Editorial Monograph Typography Block
                // SCIENTIFIC PRINCIPLE: Gestalt Law of Proximity (Wertheimer, 1923) & Cognitive Load Theory (Sweller, 1988)
                // Expanded internal padding (24px / 1.5rem equivalent) provides generous whitespace boundaries,
                // chunking information into discrete, easily digestible cognitive nodes and preventing sensory overwhelm.
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Maker Telemetry & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              specimen.maker.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: theme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '\$${specimen.estimatedUsd.toStringAsFixed(0)}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: theme.accentGlow,
                            ),
                          ),
                        ],
                      ),
                      // SCIENTIFIC PRINCIPLE: Semantic Information Disambiguation
                      // 16px inter-element gap ensures visual hierarchy separation between
                      // functional metadata (maker/price) and primary editorial semantic content (title).
                      const SizedBox(height: 16),

                      // Specimen Title (Editorial Serif)
                      Text(
                        specimen.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
