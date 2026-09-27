import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aether_commerce/models/specimen.dart';
import 'package:aether_commerce/core/theme.dart';
import 'package:aether_commerce/core/audio_controller.dart';
import 'package:aether_commerce/core/gateways/provenance_gateway.dart';
import 'package:aether_commerce/presentation/screens/specimen_detail_screen.dart';

class TestMockProvenanceGateway implements IProvenanceGateway {
  String? lastLaunchedUrl;
  bool shouldSucceed = true;

  @override
  bool isValidUrl(String url) => url.startsWith('http://') || url.startsWith('https://');

  @override
  Future<bool> canLaunchArtisanStore(String url) async => shouldSucceed && isValidUrl(url);

  @override
  Future<bool> launchArtisanStore(String url) async {
    if (shouldSucceed) {
      lastLaunchedUrl = url;
      return true;
    }
    return false;
  }
}

void main() {
  group('Phase 5: Specimen Inspector & Decompression Modal Unit Tests', () {
    const testSpecimen = DesignSpecimen(
      id: 'spec_01',
      title: 'Cast Iron Angle Desk Lamp',
      maker: 'Studio Arhoj',
      studioLocation: 'Copenhagen, Denmark',
      estimatedUsd: 185.0,
      atmosphereTag: 'rain_study',
      imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c',
      aspectRatio: 0.85,
      materialStory: 'Cast iron body with hand-spun porcelain shade.',
      provenanceUrl: 'https://arhoj.com',
      materials: ['Cast Iron', 'Spun Porcelain', 'Braided Cable'],
      isUserPinned: false,
    );

    testWidgets('Detail Screen displays monograph, materials, and handles pin toggle', (WidgetTester tester) async {
      bool pinToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SpecimenDetailScreen(
            specimen: testSpecimen,
            theme: AetherTheme.slateCharcoal,
            onPinToggle: () => pinToggled = true,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Verify Maker and Studio Location rendered
      expect(find.text('STUDIO ARHOJ • COPENHAGEN, DENMARK'), findsOneWidget);

      // 2. Verify Title and Price rendered
      expect(find.text('Cast Iron Angle Desk Lamp'), findsOneWidget);
      expect(find.text('\$185 USD'), findsOneWidget);

      // 3. Verify Material Badges
      expect(find.text('CAST IRON'), findsOneWidget);
      expect(find.text('SPUN PORCELAIN'), findsOneWidget);
      expect(find.text('BRAIDED CABLE'), findsOneWidget);

      // 4. Verify Material Craft Story
      expect(find.text('Cast iron body with hand-spun porcelain shade.'), findsOneWidget);

      // 5. Test Pin Toggle action
      final pinButton = find.byIcon(Icons.bookmark_border);
      expect(pinButton, findsOneWidget);
      await tester.tap(pinButton);
      await tester.pump();
      expect(pinToggled, true);
    });

    testWidgets('Buy / Visit Store triggers Direct Store Modal and executes intent', (WidgetTester tester) async {
      final mockGateway = TestMockProvenanceGateway();

      await tester.pumpWidget(
        MaterialApp(
          home: SpecimenDetailScreen(
            specimen: testSpecimen,
            theme: AetherTheme.slateCharcoal,
            onPinToggle: () {},
            provenanceGateway: mockGateway,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Scroll until Buy / Visit Store button is visible
      final visitButton = find.text('BUY / VISIT STORE ➔');
      expect(visitButton, findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(visitButton);
      await tester.pumpAndSettle();

      // 2. Verify Store Modal appeared with artisan context
      expect(find.text('DIRECT STORE LINK'), findsOneWidget);
      expect(find.text('Visit Studio Arhoj Store'), findsOneWidget);
      expect(find.text('https://arhoj.com'), findsOneWidget);

      // 3. Confirm visit official store intent with Labor Illusion verification
      final proceedButton = find.text('VISIT OFFICIAL STORE ➔');
      expect(proceedButton, findsOneWidget);
      await tester.tap(proceedButton);
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Labor Illusion visual feedback is actively displayed during verification
      expect(find.text('CONNECTING TO ATELIER...'), findsOneWidget);

      await tester.pumpAndSettle();

      // 4. Verify intent was launched via Provenance Gateway
      expect(mockGateway.lastLaunchedUrl, 'https://arhoj.com');
    });
  });
}
