import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aether_commerce/core/theme.dart';
import 'package:aether_commerce/core/audio_controller.dart';
import 'package:aether_commerce/presentation/widgets/audio_dock.dart';

void main() {
  group('Phase 4: Sensory Audio Dock & Visualizer Unit Tests', () {
    test('AudioEngineController volume preset cycle and mute logic', () {
      final controller = AudioEngineController();

      // Default volume is 0.8
      expect(controller.volume, 0.8);
      expect(controller.isMuted, false);

      // Cycle 1: 0.8 -> 0.70
      controller.cycleVolume();
      expect(controller.volume, closeTo(0.70, 0.01));

      // Cycle 2: 0.70 -> 0.35
      controller.cycleVolume();
      expect(controller.volume, closeTo(0.35, 0.01));

      // Cycle 3: 0.35 -> mute
      controller.cycleVolume();
      expect(controller.isMuted, true);

      // Cycle 4: mute -> 1.0 (full restore)
      controller.cycleVolume();
      expect(controller.isMuted, false);
      expect(controller.volume, 1.0);

      controller.dispose();
    });

    test('AudioEngineController amplitude stream emits continuous telemetry', () async {
      final controller = AudioEngineController();

      final firstAmplitude = await controller.amplitudeStream.first;
      expect(firstAmplitude, greaterThanOrEqualTo(0.04));
      expect(firstAmplitude, lessThanOrEqualTo(1.0));

      controller.dispose();
    });

    testWidgets('AudioDock renders telemetry, waveform, and responds to volume tap', (WidgetTester tester) async {
      final controller = AudioEngineController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AudioDock(
              audioController: controller,
              theme: AetherTheme.slateCharcoal,
              activeAtmosphereName: 'Rain & Study',
              telemetryFrequency: '800Hz–4kHz Rain Resonance',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify Telemetry displayed
      expect(find.text('RAIN & STUDY'), findsOneWidget);
      expect(find.text('800Hz–4kHz Rain Resonance'), findsOneWidget);

      // 2. Verify Play/Tune-in icon present
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // 3. Verify Volume icon button present
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

      // 4. Tap volume button to cycle
      await tester.tap(find.byIcon(Icons.volume_up_rounded));
      await tester.pump();

      // Volume cycled to 0.70 (still volume_down or volume_up)
      expect(controller.volume, closeTo(0.70, 0.01));

      controller.dispose();
    });
  });
}
