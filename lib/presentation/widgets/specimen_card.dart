import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/specimen.dart';
import '../../core/theme.dart';
import '../screens/specimen_detail_screen.dart';

class SpecimenCard extends StatelessWidget {
  final DesignSpecimen specimen;
  final AetherTheme theme;
  final VoidCallback onPinToggle;

  const SpecimenCard({
    super.key,
    required this.specimen,
    required this.theme,
    required this.onPinToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                  onPinToggle: onPinToggle,
                ),
              );
            },
          ),
        );
      },
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: theme.bgSurface,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: theme.borderHairline.withValues(alpha: 0.6),
              width: 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: specimen.aspectRatio,
                child: Hero(
                  tag: 'specimen_${specimen.id}',
                  child: CachedNetworkImage(
                    imageUrl: specimen.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 700,
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

              // Pin indicator badge in corner
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onPinToggle();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: specimen.isUserPinned
                          ? theme.accentGlow
                          : Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      specimen.isUserPinned
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
