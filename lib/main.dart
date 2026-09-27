import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/audio_controller.dart';
import 'data/catalog_repository.dart';
import 'presentation/screens/canvas_screen.dart';

void main() async {
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

  final repository = CatalogRepository();
  await repository.init();

  final audioController = AudioEngineController();

  runApp(AetherApp(
    repository: repository,
    audioController: audioController,
  ));
}

class AetherApp extends StatelessWidget {
  final CatalogRepository repository;
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
