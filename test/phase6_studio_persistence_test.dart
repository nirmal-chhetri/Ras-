import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aether_commerce/models/specimen.dart';
import 'package:aether_commerce/core/theme.dart';
import 'package:aether_commerce/core/gateways/storage_gateway.dart';
import 'package:aether_commerce/data/catalog_repository.dart';
import 'package:aether_commerce/presentation/screens/studio_drawer.dart';

class InMemoryStorageGateway implements IStorageGateway {
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
        )
      ];

  @override
  Future<List<DesignSpecimen>> loadBaseCatalog() async => [
        const DesignSpecimen(
          id: 'seed_01',
          title: 'Cast Iron Angle Desk Lamp',
          maker: 'Studio Arhoj',
          studioLocation: 'Copenhagen',
          estimatedUsd: 185.0,
          atmosphereTag: 'rain_study',
          imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c',
          aspectRatio: 0.85,
          materialStory: 'Story',
          provenanceUrl: 'https://arhoj.com',
          materials: ['Cast Iron'],
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
  Future<void> persistPreference(String key, String value) async {}

  @override
  Future<String?> readPreference(String key) async => null;
}

void main() {
  group('Phase 6: Personal Studio Moodboard & Ingestion Persistence Tests', () {
    test('Offline Persistence: pins and custom specimens survive app relaunch', () async {
      // Shared persistent store instance representing disk storage
      final persistentStorage = InMemoryStorageGateway();

      // Session 1: App launches, pins an item, adds a custom artisan piece
      final session1Repo = CatalogRepository(storageGateway: persistentStorage);
      await session1Repo.init();
      expect(session1Repo.pinnedSpecimens.length, 0);

      // Pin the seed specimen
      session1Repo.togglePin('seed_01');
      expect(session1Repo.pinnedSpecimens.length, 1);

      // Add a custom clipped artisan specimen
      const customPiece = DesignSpecimen(
        id: 'custom_artisan_99',
        title: 'Walnut Record Console',
        maker: 'Independent Carpenter',
        studioLocation: 'Portland, OR',
        estimatedUsd: 850.0,
        atmosphereTag: 'rain_study',
        imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c',
        aspectRatio: 1.1,
        materialStory: 'Solid American black walnut with brass joinery.',
        provenanceUrl: 'https://artisan-studio.example',
        materials: ['Walnut', 'Solid Brass'],
        isUserPinned: true,
      );
      session1Repo.addCustomSpecimen(customPiece);
      expect(session1Repo.pinnedSpecimens.length, 2);

      // --- SIMULATE APP KILL & RESTART ---
      // Session 2: Fresh repository instance boots from the persistent storage
      final session2Repo = CatalogRepository(storageGateway: persistentStorage);
      await session2Repo.init();

      // Assert both the pinned catalog specimen and custom clipped piece persisted!
      expect(session2Repo.pinnedSpecimens.length, 2);
      final pinnedIds = session2Repo.pinnedSpecimens.map((s) => s.id).toSet();
      expect(pinnedIds.contains('seed_01'), true);
      expect(pinnedIds.contains('custom_artisan_99'), true);

      // Assert custom specimen retained metadata
      final restoredCustom = session2Repo.pinnedSpecimens.firstWhere((s) => s.id == 'custom_artisan_99');
      expect(restoredCustom.maker, 'Independent Carpenter');
      expect(restoredCustom.estimatedUsd, 850.0);
    });

    testWidgets('StudioDrawer renders investment telemetry and allows unpinning', (WidgetTester tester) async {
      final pinnedList = [
        const DesignSpecimen(
          id: 'p_01',
          title: 'Akari 1A',
          maker: 'Noguchi',
          studioLocation: 'Japan',
          estimatedUsd: 220.0,
          atmosphereTag: 'rain_study',
          imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c',
          aspectRatio: 1.0,
          materialStory: 'Washi paper',
          provenanceUrl: 'https://noguchi.org',
          materials: ['Washi'],
          isUserPinned: true,
        ),
      ];

      String? unpinnedId;

      await tester.pumpWidget(
        MaterialApp(
          home: StudioDrawer(
            pinnedSpecimens: pinnedList,
            theme: AetherTheme.slateCharcoal,
            onUnpin: (id) => unpinnedId = id,
            onAddCustom: (_) {},
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify Telemetry bar
      expect(find.text('1 SPECIMENS CURATED'), findsOneWidget);
      expect(find.text('\$220 USD'), findsOneWidget);

      // 2. Verify Specimen rendered
      expect(find.text('NOGUCHI'), findsOneWidget);
      expect(find.text('Akari 1A'), findsOneWidget);

      // 3. Tap close/unpin button on card
      final unpinButton = find.byKey(const Key('unpin_p_01'));
      expect(unpinButton, findsOneWidget);
      await tester.tap(unpinButton);
      await tester.pump();
      expect(unpinnedId, 'p_01');
    });
  });
}
