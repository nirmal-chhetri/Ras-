import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aether_commerce/main.dart';
import 'package:aether_commerce/models/specimen.dart';
import 'package:aether_commerce/core/theme.dart';
import 'package:aether_commerce/core/audio_controller.dart';
import 'package:aether_commerce/core/gateways/storage_gateway.dart';
import 'package:aether_commerce/data/catalog_repository.dart';
import 'package:aether_commerce/presentation/screens/canvas_screen.dart';
import 'package:aether_commerce/presentation/screens/specimen_detail_screen.dart';
import 'package:aether_commerce/presentation/widgets/specimen_card.dart';

/// Test storage gateway supporting preferences map for reload persistence testing
class TestPreferencesStorageGateway implements IStorageGateway {
  final Map<String, String> _preferences = {};
  final Set<String> _pinned = {};
  final List<DesignSpecimen> _custom = [];

  @override
  Future<List<Atmosphere>> loadAtmospheres() async => [
        const Atmosphere(
          id: 'rain_study',
          displayName: 'Rain & Study',
          tagline: 'Slate charcoal',
          audioTrack: 'assets/audio/rain_study.ogg',
          telemetryFrequency: '800Hz',
          colorTheme: 'slate',
        ),
        const Atmosphere(
          id: 'raw_terracotta',
          displayName: 'Raw Terracotta',
          tagline: 'Warm travertine',
          audioTrack: 'assets/audio/raw_terracotta.wav',
          telemetryFrequency: '432Hz',
          colorTheme: 'warm_travertine',
        ),
      ];

  @override
  Future<List<DesignSpecimen>> loadBaseCatalog() async => [
        const DesignSpecimen(
          id: 'spec_01',
          title: 'Cast Iron Angle Desk Lamp',
          maker: 'Studio Arhoj',
          studioLocation: 'Copenhagen, Denmark',
          estimatedUsd: 185.0,
          atmosphereTag: 'rain_study',
          imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c',
          aspectRatio: 0.85,
          materialStory: 'Cast iron with powder-coated brass joints.',
          provenanceUrl: 'https://arhoj.com',
          materials: ['Cast Iron', 'Brass'],
          isUserPinned: false,
        ),
        const DesignSpecimen(
          id: 'spec_02',
          title: 'Wabi-Sabi Ceramic Matcha Chawan',
          maker: 'Kazuya Ishida',
          studioLocation: 'Bizen, Japan',
          estimatedUsd: 240.0,
          atmosphereTag: 'raw_terracotta',
          imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61',
          aspectRatio: 1.0,
          materialStory: 'Wood-fired unglazed stoneware bowl.',
          provenanceUrl: 'https://bizenware.jp',
          materials: ['Unglazed Stoneware'],
          isUserPinned: false,
        ),
      ];

  @override
  Future<Set<String>> loadPinnedIds() async => Set.from(_pinned);

  @override
  Future<void> persistPinnedIds(Set<String> pinnedIds) async {
    _pinned.clear();
    _pinned.addAll(pinnedIds);
  }

  @override
  Future<List<DesignSpecimen>> loadCustomSpecimens() async => List.from(_custom);

  @override
  Future<void> saveCustomSpecimen(DesignSpecimen specimen) async {
    _custom.removeWhere((s) => s.id == specimen.id);
    _custom.insert(0, specimen);
  }

  @override
  Future<void> removeCustomSpecimen(String specimenId) async {
    _custom.removeWhere((s) => s.id == specimenId);
  }

  @override
  Future<void> persistPreference(String key, String value) async {
    _preferences[key] = value;
  }

  @override
  Future<String?> readPreference(String key) async => _preferences[key];
}

void main() {
  group('Web Optimization & Edge Case Verification Tests', () {
    late TestPreferencesStorageGateway storage;
    late CatalogRepository repository;
    late AudioEngineController audioController;

    setUp(() async {
      storage = TestPreferencesStorageGateway();
      repository = CatalogRepository(storageGateway: storage);
      await repository.init();
      audioController = AudioEngineController();
    });

    testWidgets('Deep Linking / Browser Refresh: Directly navigating to /specimen/:id mounts SpecimenDetailScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/specimen/spec_01',
          onGenerateRoute: (settings) {
            var routePath = settings.name ?? '/';
            if (routePath.startsWith('/#')) routePath = routePath.substring(2);
            if (routePath.startsWith('#')) routePath = routePath.substring(1);
            if (!routePath.startsWith('/')) routePath = '/$routePath';

            final uri = Uri.tryParse(routePath) ?? Uri(path: '/');
            if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'specimen') {
              final specimenId = uri.pathSegments.length >= 2 ? uri.pathSegments[1] : '';
              final matched = repository.specimens.where((s) => s.id == specimenId);
              if (matched.isNotEmpty) {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => SpecimenDetailScreen(
                    specimen: matched.first,
                    theme: AetherTheme.slateCharcoal,
                    onPinToggle: () {},
                  ),
                );
              }
            }
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => CanvasScreen(
                repository: repository,
                audioController: audioController,
              ),
            );
          },
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verifies the monograph screen is directly displayed without falling back to CanvasScreen
      expect(find.byType(SpecimenDetailScreen), findsOneWidget);
      expect(find.text('Cast Iron Angle Desk Lamp'), findsOneWidget);
      expect(find.text('STUDIO ARHOJ • COPENHAGEN, DENMARK'), findsOneWidget);
    });

    testWidgets('Hash Deep Linking: Handles #/specimen/:id syntax gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        AetherApp(
          repository: repository,
          audioController: audioController,
        ),
      );

      // Simulates browser address bar navigation with hash routing
      Navigator.of(tester.element(find.byType(CanvasScreen)))
          .pushNamed('#/specimen/spec_02');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(SpecimenDetailScreen), findsOneWidget);
      expect(find.text('Wabi-Sabi Ceramic Matcha Chawan'), findsOneWidget);
    });

    testWidgets('Unknown route fallback: gracefully defaults to CanvasScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/specimen/non_existent_id',
          onGenerateRoute: (settings) {
            var routePath = settings.name ?? '/';
            if (routePath.startsWith('/#')) routePath = routePath.substring(2);
            if (routePath.startsWith('#')) routePath = routePath.substring(1);
            if (!routePath.startsWith('/')) routePath = '/$routePath';

            final uri = Uri.tryParse(routePath) ?? Uri(path: '/');
            if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'specimen') {
              final specimenId = uri.pathSegments.length >= 2 ? uri.pathSegments[1] : '';
              final matched = repository.specimens.where((s) => s.id == specimenId);
              if (matched.isNotEmpty) {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (context) => SpecimenDetailScreen(
                    specimen: matched.first,
                    theme: AetherTheme.slateCharcoal,
                    onPinToggle: () {},
                  ),
                );
              }
            }
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => CanvasScreen(
                repository: repository,
                audioController: audioController,
              ),
            );
          },
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Defaults smoothly to CanvasScreen instead of crashing
      expect(find.byType(CanvasScreen), findsOneWidget);
    });

    testWidgets('Reload Redirection Safety: Back button redirects to / if canPop is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/detail',
          routes: {
            '/': (context) => const Scaffold(body: Text('HOME_SCREEN')),
            '/detail': (context) => SpecimenDetailScreen(
                  specimen: repository.specimens.first,
                  theme: AetherTheme.slateCharcoal,
                  onPinToggle: () {},
                ),
          },
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // On direct reload, canPop is false. Tapping back triggers pushReplacementNamed('/')
      final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('HOME_SCREEN'), findsOneWidget);
    });

    testWidgets('Session Persistence: Active atmosphere persists across canvas screen remounts',
        (WidgetTester tester) async {
      // 1. Manually persist Raw Terracotta atmosphere selection
      await storage.persistPreference('active_atmosphere_id', 'raw_terracotta');

      // 2. Mount CanvasScreen (simulating page refresh)
      await tester.pumpWidget(
        MaterialApp(
          home: CanvasScreen(
            repository: repository,
            audioController: audioController,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 3. Verify Raw Terracotta was restored on the top-bar capsule
      expect(find.text('ATMOSPHERE: RAW TERRACOTTA'), findsOneWidget);
    });

    testWidgets('CachedNetworkImage in SpecimenCard enforces memory bounds',
        (WidgetTester tester) async {
      final specimen = repository.specimens.first;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpecimenCard(
              specimen: specimen,
              theme: AetherTheme.slateCharcoal,
              onPinToggle: () {},
            ),
          ),
        ),
      );

      await tester.pump();

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );

      // CanvasKit WebGL texture bounds assertions
      expect(cachedImage.memCacheWidth, 600);
      expect(cachedImage.memCacheHeight, 800);
      expect(cachedImage.maxWidthDiskCache, 800);
      expect(cachedImage.maxHeightDiskCache, 1000);
    });
  });
}
