import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aether_commerce/models/specimen.dart';
import 'package:aether_commerce/core/theme.dart';
import 'package:aether_commerce/core/theme_manager.dart';
import 'package:aether_commerce/presentation/widgets/specimen_card.dart';

void main() {
  group('Phase 3: Visual Canvas & Masonry Feed Unit Tests', () {
    test('ThemeManager switches palettes and notifies listeners', () {
      final themeManager = ThemeManager(initialTheme: AetherTheme.slateCharcoal);
      int notificationCount = 0;
      themeManager.addListener(() => notificationCount++);

      expect(themeManager.activeAtmosphereId, 'rain_study');
      expect(themeManager.currentTheme.bgPrimary, const Color(0xFF16181D));

      // 1. Switch to Tokyo Nocturne
      themeManager.switchAtmosphere('tokyo_nocturne');
      expect(themeManager.activeAtmosphereId, 'tokyo_nocturne');
      expect(themeManager.currentTheme.bgPrimary, const Color(0xFF0B0C10));
      expect(notificationCount, 1);

      // 2. Switch to Raw Terracotta
      themeManager.switchAtmosphere('raw_terracotta');
      expect(themeManager.activeAtmosphereId, 'raw_terracotta');
      expect(themeManager.currentTheme.bgPrimary, const Color(0xFFF5F2EB));
      expect(notificationCount, 2);

      // 3. Re-switching to same atmosphere does not fire redundant notification
      themeManager.switchAtmosphere('raw_terracotta');
      expect(notificationCount, 2);
    });

    test('ThemeManager configurable animation parameters', () {
      final themeManager = ThemeManager();
      expect(themeManager.animationDuration, const Duration(milliseconds: 400));
      expect(themeManager.animationCurve, Curves.easeInOutCubic);

      themeManager.setTransitionConfig(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
      );

      expect(themeManager.animationDuration, const Duration(milliseconds: 250));
      expect(themeManager.animationCurve, Curves.fastOutSlowIn);
    });

    test('AetherTheme slateCharcoal implements anti-halation contrast', () {
      const theme = AetherTheme.slateCharcoal;
      expect(theme.textPrimary, const Color(0xFFEAEAEA));
      expect(theme.bgSurface, const Color(0xFF1A1C23));
    });

    testWidgets('SpecimenCard displays maker, title, price and handles pin toggle', (WidgetTester tester) async {
      const specimen = DesignSpecimen(
        id: 'spec_widget_test',
        title: 'Akari 1A Lamp',
        maker: 'Isamu Noguchi',
        studioLocation: 'Gifu, Japan',
        estimatedUsd: 220.0,
        atmosphereTag: 'rain_study',
        imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c',
        aspectRatio: 0.85,
        materialStory: 'Washi paper and bamboo ribbing with cast iron legs.',
        provenanceUrl: 'https://noguchi.org',
        materials: ['Washi Paper', 'Bamboo', 'Cast Iron'],
        isUserPinned: false,
      );

      bool pinToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                child: SpecimenCard(
                  specimen: specimen,
                  theme: AetherTheme.slateCharcoal,
                  onPinToggle: () => pinToggled = true,
                ),
              ),
            ),
          ),
        ),
      );

      // Advance frames past entrance animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify typography elements rendered
      expect(find.text('ISAMU NOGUCHI'), findsOneWidget);
      expect(find.text('Akari 1A Lamp'), findsOneWidget);
      expect(find.text('\$220'), findsOneWidget);

      // Tap bookmark pin icon
      await tester.tap(find.byIcon(Icons.bookmark_border));
      expect(pinToggled, true);
    });
  });
}
