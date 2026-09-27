import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aether_commerce/models/specimen.dart';
import 'package:aether_commerce/core/theme.dart';
import 'package:aether_commerce/core/audio_controller.dart';
import 'package:aether_commerce/presentation/widgets/specimen_card.dart';
import 'package:aether_commerce/presentation/widgets/audio_dock.dart';
import 'package:aether_commerce/presentation/screens/specimen_detail_screen.dart';

void main() {
  group('Phase 7: Evaluator Edge Case Verification & Lab Demo Tests', () {
    const testSpecimen = DesignSpecimen(
      id: 'spec_eval_01',
      title: 'Monochrome OLED Telemetry Clock with Extremely Long Descriptive Name',
      maker: 'Tidbyt Atelier Artisanal Electronics Studio',
      studioLocation: 'Brooklyn, New York, United States',
      estimatedUsd: 199.0,
      atmosphereTag: 'rain_study',
      imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c',
      aspectRatio: 1.0,
      materialStory: 'Enclosed in solid walnut with a matte diffusion acrylic faceplate.',
      provenanceUrl: 'https://tidbyt.com',
      materials: ['Solid Walnut', 'Matte Acrylic', 'OLED Glass'],
      isUserPinned: true,
    );

    testWidgets('Accessibility Test: SpecimenCard survives 200% font scaling without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            // Simulate 200% accessibility system font scaling
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2.0),
              ),
              child: child!,
            );
          },
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 260,
                child: SpecimenCard(
                  specimen: testSpecimen,
                  theme: AetherTheme.slateCharcoal,
                  onPinToggle: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Assert that typography scales gracefully without causing RenderFlex overflow
      expect(find.byType(SpecimenCard), findsOneWidget);
    });

    testWidgets('Accessibility Test: AudioDock survives 200% font scaling without overflow', (WidgetTester tester) async {
      final controller = AudioEngineController();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2.0),
              ),
              child: child!,
            );
          },
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
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(AudioDock), findsOneWidget);
      controller.dispose();
    });

    testWidgets('Detail Screen survives 200% font scaling and deep scroll', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2.0),
              ),
              child: child!,
            );
          },
          home: SpecimenDetailScreen(
            specimen: testSpecimen,
            theme: AetherTheme.obsidianNeon,
            onPinToggle: () {},
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SpecimenDetailScreen), findsOneWidget);
      expect(find.text('Monochrome OLED Telemetry Clock with Extremely Long Descriptive Name'), findsOneWidget);
    });
  });
}
