import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/specimen.dart';
import '../../core/theme.dart';
import '../screens/specimen_detail_screen.dart';

class SpecimenCard extends StatefulWidget {
  final DesignSpecimen specimen;
  final AetherTheme theme;
  final VoidCallback onPinToggle;
  final int index;

  const SpecimenCard({
    super.key,
    required this.specimen,
    required this.theme,
    required this.onPinToggle,
    this.index = 0,
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
                  color: Colors.black.withValues(alpha: _isHovered ? 0.18 : 0.06),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: Offset(0, _isHovered ? 6 : 3),
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
                          memCacheWidth: 750,
                          placeholder: (context, url) => Container(
                            color: theme.bgSurface,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: theme.textSecondary.withValues(alpha: 0.4),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
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
                      const SizedBox(height: 4),

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
