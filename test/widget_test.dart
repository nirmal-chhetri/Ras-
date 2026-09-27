import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aether_commerce/models/specimen.dart';
import 'package:aether_commerce/core/theme.dart';

/// ============================================================================
/// FILE: test/widget_test.dart
/// ARCHITECTURE LAYER: Regression & Smoke Unit Tests
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// This test file serves as a fast baseline regression and sanity check verifying:
/// 1. Atmospheric theme resolution across all 3 curated biomes.
/// 2. Immutability guarantees on [DesignSpecimen] copy operations.
/// ============================================================================

void main() {
  group('Aether Ambient Slow-Commerce Smoke & Sanity Unit Tests', () {
    test('Theme morphing resolves correct palettes across all atmospheres', () {
      final rainTheme = AetherTheme.fromAtmosphereId('rain_study');
      expect(rainTheme.id, 'rain_study');
      expect(rainTheme.bgPrimary, const Color(0xFF16181D));

      final obsidianTheme = AetherTheme.fromAtmosphereId('tokyo_nocturne');
      expect(obsidianTheme.id, 'tokyo_nocturne');
      expect(obsidianTheme.bgPrimary, const Color(0xFF0B0C10));

      final travertineTheme = AetherTheme.fromAtmosphereId('raw_terracotta');
      expect(travertineTheme.id, 'raw_terracotta');
      expect(travertineTheme.bgPrimary, const Color(0xFFF5F2EB));
    });

    test('Specimen copyWith maintains immutability and updates fields', () {
      const specimen = DesignSpecimen(
        id: 's_test',
        title: 'Original Title',
        maker: 'Artisan',
        studioLocation: 'Kyoto',
        estimatedUsd: 150.0,
        atmosphereTag: 'rain_study',
        imageUrl: 'https://images.unsplash.com/test',
        aspectRatio: 0.9,
        materialStory: 'Story',
        provenanceUrl: 'https://example.com',
        materials: ['Wood', 'Linen'],
        isUserPinned: false,
      );

      final pinned = specimen.copyWith(isUserPinned: true);
      expect(specimen.isUserPinned, false);
      expect(pinned.isUserPinned, true);
      expect(pinned.id, specimen.id);
      expect(pinned.title, specimen.title);
    });
  });
}
