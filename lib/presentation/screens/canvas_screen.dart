import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/audio_controller.dart';
import '../../data/catalog_repository.dart';
import '../widgets/atmosphere_selector.dart';
import '../widgets/specimen_card.dart';
import '../widgets/audio_dock.dart';
import 'studio_drawer.dart';

class CanvasScreen extends StatefulWidget {
  final CatalogRepository repository;
  final AudioEngineController audioController;

  const CanvasScreen({
    super.key,
    required this.repository,
    required this.audioController,
  });

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  String _activeAtmosphereId = 'rain_study';

  @override
  void initState() {
    super.initState();
    // Start initial atmosphere audio loop
    final initialAtmos = widget.repository.atmospheres.firstWhere(
      (a) => a.id == _activeAtmosphereId,
      orElse: () => widget.repository.atmospheres.first,
    );
    widget.audioController.switchAtmosphereAudio(initialAtmos.audioTrack);
  }

  void _onAtmosphereChanged(String newId) {
    if (_activeAtmosphereId == newId) return;
    setState(() {
      _activeAtmosphereId = newId;
    });

    final atmos = widget.repository.atmospheres.firstWhere((a) => a.id == newId);
    widget.audioController.switchAtmosphereAudio(atmos.audioTrack);
  }

  void _openStudioDrawer(AetherTheme theme) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: StudioDrawer(
              pinnedSpecimens: widget.repository.pinnedSpecimens,
              theme: theme,
              onUnpin: (id) {
                setState(() {
                  widget.repository.togglePin(id);
                });
              },
              onAddCustom: (newSpecimen) {
                setState(() {
                  widget.repository.addCustomSpecimen(newSpecimen);
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AetherTheme.fromAtmosphereId(_activeAtmosphereId);
    final displayedSpecimens = widget.repository.getByAtmosphere(_activeAtmosphereId);
    final activeAtmos = widget.repository.atmospheres.firstWhere(
      (a) => a.id == _activeAtmosphereId,
      orElse: () => widget.repository.atmospheres.first,
    );
    final pinnedCount = widget.repository.pinnedSpecimens.length;

    return AnimatedTheme(
      data: theme.toThemeData(),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      child: Scaffold(
        backgroundColor: theme.bgPrimary,
        body: Stack(
          children: [
            // Primary Masonry Scroll Canvas
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Minimalist Top App Bar
                SliverSafeArea(
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AtmosphereSelector(
                            atmospheres: widget.repository.atmospheres,
                            activeId: _activeAtmosphereId,
                            theme: theme,
                            onAtmosphereSelected: _onAtmosphereChanged,
                          ),
                          GestureDetector(
                            onTap: () => _openStudioDrawer(theme),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.bgSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.borderHairline.withValues(alpha: 0.8),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'STUDIO ($pinnedCount)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: pinnedCount > 0 ? theme.accentGlow : theme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2-Column Staggered Masonry Grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    itemBuilder: (context, index) {
                      final specimen = displayedSpecimens[index];
                      return SpecimenCard(
                        specimen: specimen,
                        theme: theme,
                        onPinToggle: () {
                          setState(() {
                            widget.repository.togglePin(specimen.id);
                          });
                        },
                      );
                    },
                    childCount: displayedSpecimens.length,
                  ),
                ),
              ],
            ),

            // Persistent Floating Ambient Audio Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: AudioDock(
                  audioController: widget.audioController,
                  theme: theme,
                  activeAtmosphereName: activeAtmos.displayName,
                  telemetryFrequency: activeAtmos.telemetryFrequency,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
