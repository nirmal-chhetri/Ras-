import 'package:test/test.dart';
import 'package:aether_commerce/models/specimen.dart';

void main() {
  group('Aether Deterministic Verifier Unit Tests', () {
    test('Aspect Ratio Clamping Verifier Bounds', () {
      double clampAspectRatio(double rawRatio) {
        if (rawRatio < 0.75) return 0.75;
        if (rawRatio > 1.33) return 1.33;
        return rawRatio;
      }

      // Test extreme vertical image
      expect(clampAspectRatio(0.50), 0.75);
      
      // Test extreme horizontal panorama
      expect(clampAspectRatio(2.10), 1.33);

      // Test valid golden aspect ratios
      expect(clampAspectRatio(0.85), 0.85);
      expect(clampAspectRatio(1.00), 1.00);
      expect(clampAspectRatio(1.25), 1.25);
    });

    test('DesignSpecimen JSON serialization & copyWith', () {
      const specimen = DesignSpecimen(
        id: 'test_01',
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

      final json = specimen.toJson();
      expect(json['id'], 'test_01');
      expect(json['maker'], 'Isamu Noguchi');
      expect(json['materials'].length, 3);

      final updated = specimen.copyWith(isUserPinned: true);
      expect(updated.isUserPinned, true);
      expect(updated.title, 'Akari 1A Lamp');
    });

    test('Atmosphere Model Invariant Mapping', () {
      const atmos = Atmosphere(
        id: 'tokyo_nocturne',
        displayName: 'Tokyo Nocturne',
        tagline: 'Obsidian tech and midnight breeze',
        audioTrack: 'assets/audio/tokyo_nocturne.wav',
        telemetryFrequency: '60Hz Sub-Drone',
        colorTheme: 'obsidian_neon',
      );

      expect(atmos.id, 'tokyo_nocturne');
      expect(atmos.audioTrack.endsWith('.wav'), true);
      expect(atmos.telemetryFrequency.contains('60Hz'), true);
    });
  });
}
