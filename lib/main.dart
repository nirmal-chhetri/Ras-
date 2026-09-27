import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/audio_controller.dart';
import 'data/catalog_repository.dart';
import 'presentation/screens/canvas_screen.dart';
import 'presentation/screens/specimen_detail_screen.dart';

/// ============================================================================
/// FILE: lib/main.dart
/// ARCHITECTURE LAYER: Application Bootstrapper & Root Widget (Phase 1)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// This is the primary execution entry point for the Aether desktop, web, and
/// mobile application.
///
/// BOOT SEQUENCE:
/// 1. [WidgetsFlutterBinding.ensureInitialized]:
///    Guarantees asynchronous service bindings (channel communication, asset
///    bundle loading, system preferences) are fully operational before execution.
///
/// 2. Immersive System Navigation ([SystemChrome.setSystemUIOverlayStyle]):
///    Configures transparent status bars and system navigation bars to ensure
///    the broadsheet visual imagery and frosted glass dock bleed edge-to-edge.
///
/// 3. Data Repository Bootstrapping:
///    Instantiates and awaits [CatalogRepository.init], loading baseline specimens
///    from DATA_CATALOG.json and cached user studio pins from local storage.
///
/// 4. Sensory Audio Engine Bootstrapping:
///    Instantiates [AudioEngineController], priming the audio player and
///    biological waveform visualizer stream.
///
/// 5. Root Material Application & Web Deep Linking:
///    Mounts [AetherApp] with [onGenerateRoute], supporting web browser refresh
///    retention for '/specimen/:id' without resetting to the home canvas.
/// ============================================================================

void main() async {
  // Ensure framework services are initialized for async asset and storage calls
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive edge-to-edge transparent system navigation
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize the catalog repository and restore cached state
  final repository = CatalogRepository();
  await repository.init();

  // Initialize the ambient audio engine controller
  final audioController = AudioEngineController();

  // Launch the root application widget
  runApp(AetherApp(
    repository: repository,
    audioController: audioController,
  ));
}

/// Root widget configuring the Material application shell and global theme defaults.
class AetherApp extends StatelessWidget {
  /// The global catalog repository holding specimens and atmosphere definitions.
  final CatalogRepository repository;

  /// The sensory audio engine controller driving soundscapes and telemetry.
  final AudioEngineController audioController;

  const AetherApp({
    super.key,
    required this.repository,
    required this.audioController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aether • Ambient Slow Commerce',
      debugShowCheckedModeBanner: false,
      theme: AetherTheme.slateCharcoal.toThemeData(),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        var routePath = settings.name ?? '/';
        // Normalize hash-based web URLs (e.g. '/#/specimen/spec_01' or '#/specimen/spec_01')
        if (routePath.startsWith('/#')) {
          routePath = routePath.substring(2);
        } else if (routePath.startsWith('#')) {
          routePath = routePath.substring(1);
        }
        if (!routePath.startsWith('/')) {
          routePath = '/$routePath';
        }

        final uri = Uri.tryParse(routePath) ?? Uri(path: '/');

        // WEB REFRESH & DEEP LINKING: /specimen/:id
        // When the user reloads the browser while inspecting an artisanal monograph,
        // this route generator resolves the specimen ID and restores the detail screen
        // directly, preserving user context rather than resetting to home.
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'specimen') {
          final specimenId =
              uri.pathSegments.length >= 2 ? uri.pathSegments[1] : '';
          final matched =
              repository.specimens.where((s) => s.id == specimenId);
          if (matched.isNotEmpty) {
            final specimen = matched.first;
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 350),
              reverseTransitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return FadeTransition(
                  opacity: animation,
                  child: SpecimenDetailScreen(
                    specimen: specimen,
                    theme: AetherTheme.fromAtmosphereId(specimen.atmosphereTag),
                    audioController: audioController,
                    onPinToggle: () => repository.togglePin(specimen.id),
                  ),
                );
              },
            );
          }
        }

        // Default canonical route: Discovery canvas
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) {
            return CanvasScreen(
              repository: repository,
              audioController: audioController,
            );
          },
        );
      },
    );
  }
}
