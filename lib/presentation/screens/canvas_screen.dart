import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/theme_manager.dart';
import '../../core/audio_controller.dart';
import '../../data/catalog_repository.dart';
import '../widgets/atmosphere_selector.dart';
import '../widgets/specimen_card.dart';
import '../widgets/audio_dock.dart';
import 'studio_drawer.dart';

class CanvasScreen extends StatefulWidget {
  final CatalogRepository repository;
  final AudioEngineController audioController;
  final ThemeManager? themeManager;

  const CanvasScreen({
    super.key,
    required this.repository,
    required this.audioController,
    this.themeManager,
  });

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  late final ThemeManager _themeManager;
  String _activeAtmosphereId = 'rain_study';
  bool _showPinnedOnly = false;

  @override
  void initState() {
    super.initState();
    _themeManager = widget.themeManager ?? ThemeManager();
    _themeManager.addListener(_onThemeChanged);

    // Prime the audio engine with initial atmospheric track
    final initialAtmos = widget.repository.atmospheres.firstWhere(
      (a) => a.id == _activeAtmosphereId,
      orElse: () => widget.repository.atmospheres.first,
    );
    widget.audioController.switchAtmosphereAudio(initialAtmos.audioTrack);
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _onAtmosphereChanged(String newId) {
    if (_activeAtmosphereId == newId) return;
    setState(() {
      _activeAtmosphereId = newId;
    });

    _themeManager.switchAtmosphere(newId);
    final atmos = widget.repository.atmospheres.firstWhere((a) => a.id == newId);
    widget.audioController.switchAtmosphereAudio(atmos.audioTrack);
  }

  void _openStudioDrawer(AetherTheme theme) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
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
    final theme = _themeManager.currentTheme;
    final activeAtmos = widget.repository.atmospheres.firstWhere(
      (a) => a.id == _activeAtmosphereId,
      orElse: () => widget.repository.atmospheres.first,
    );

    var displayedSpecimens = widget.repository.getByAtmosphere(_activeAtmosphereId);
    if (_showPinnedOnly) {
      displayedSpecimens = displayedSpecimens.where((s) => s.isUserPinned).toList();
    }
    final pinnedCount = widget.repository.pinnedSpecimens.length;

    return AnimatedTheme(
      data: theme.toThemeData(),
      duration: _themeManager.animationDuration,
      curve: _themeManager.animationCurve,
      child: Scaffold(
        backgroundColor: theme.bgPrimary,
        body: Stack(
          children: [
            // Primary Masonry Scroll Canvas
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Editorial Broadsheet Top Bar
                SliverSafeArea(
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.bgSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: pinnedCount > 0
                                      ? theme.accentGlow.withValues(alpha: 0.6)
                                      : theme.borderHairline.withValues(alpha: 0.8),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_mosaic_outlined,
                                    size: 13,
                                    color: pinnedCount > 0 ? theme.accentGlow : theme.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'STUDIO ($pinnedCount)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: pinnedCount > 0 ? theme.accentGlow : theme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Broadsheet Masthead Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AETHER SANCTUARY • VOL. 01',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.6,
                                color: theme.textSecondary,
                              ),
                            ),
                            Text(
                              activeAtmos.telemetryFrequency.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9.0,
                                fontWeight: FontWeight.w600,
                                color: theme.accentGlow,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activeAtmos.tagline,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: theme.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Sub-filter tabs (All vs Pinned in atmosphere)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_showPinnedOnly) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _showPinnedOnly = false);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !_showPinnedOnly
                                      ? theme.textPrimary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: !_showPinnedOnly
                                        ? theme.textPrimary
                                        : theme.borderHairline,
                                  ),
                                ),
                                child: Text(
                                  'ALL SPECIMENS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: !_showPinnedOnly
                                        ? theme.bgPrimary
                                        : theme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (!_showPinnedOnly) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _showPinnedOnly = true);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _showPinnedOnly
                                      ? theme.textPrimary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _showPinnedOnly
                                        ? theme.textPrimary
                                        : theme.borderHairline,
                                  ),
                                ),
                                child: Text(
                                  'CURATED IN ATMOSPHERE',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: _showPinnedOnly
                                        ? theme.bgPrimary
                                        : theme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. 2-Column Staggered Masonry Grid Feed
                if (displayedSpecimens.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 40,
                              color: theme.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No pinned specimens in this atmosphere',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                color: theme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Explore all specimens and tap the bookmark to curate your room.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: theme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      itemBuilder: (context, index) {
                        final specimen = displayedSpecimens[index];
                        return SpecimenCard(
                          index: index,
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

            // Persistent Floating Sensory Audio Dock
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
