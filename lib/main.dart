import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/audio_controller.dart';
import 'data/catalog_repository.dart';
import 'presentation/screens/canvas_screen.dart';

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
/// 5. Root Material Application:
///    Mounts [AetherApp] with the default Slate Charcoal theme and routes
///    directly to [CanvasScreen].
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
      home: CanvasScreen(
        repository: repository,
        audioController: audioController,
      ),
    );
  }
}
