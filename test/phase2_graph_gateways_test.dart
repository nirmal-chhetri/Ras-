import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:aether_commerce/models/specimen.dart';
import 'package:aether_commerce/core/verifiers/deterministic_verifiers.dart';
import 'package:aether_commerce/core/gateways/audio_gateway.dart';
import 'package:aether_commerce/core/gateways/storage_gateway.dart';
import 'package:aether_commerce/core/gateways/provenance_gateway.dart';
import 'package:aether_commerce/core/state/atmosphere_state_machine.dart';
import 'package:aether_commerce/core/pipelines/ingestion_pipeline.dart';

// Test Mock Implementations for Headless Testing
class MockAudioGateway implements IAudioGateway {
  String? lastPlayedAsset;
  double volume = 0.8;
  bool isMuted = false;
  bool externalAudioActive = false;
  final Stream<double> _stream = Stream.value(0.4);

  @override
  Future<void> initAudioSession() async {}

  @override
  Future<void> crossfadeTo(String trackAsset, {Duration duration = const Duration(milliseconds: 400)}) async {
    lastPlayedAsset = trackAsset;
  }

  @override
  Future<void> setVolume(double v) async {
    volume = v;
  }

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> setMuted(bool muted) async {
    isMuted = muted;
  }

  @override
  Stream<double> get amplitudeStream => _stream;

  @override
  Future<bool> checkExternalAudioActive() async => externalAudioActive;

  @override
  void dispose() {}
}

class MockStorageGateway implements IStorageGateway {
  final List<DesignSpecimen> customSaved = [];
  final Set<String> pinned = {};

  @override
  Future<List<Atmosphere>> loadAtmospheres() async => [];

  @override
  Future<List<DesignSpecimen>> loadBaseCatalog() async => [];

  @override
  Future<Set<String>> loadPinnedIds() async => pinned;

  @override
  Future<void> persistPinnedIds(Set<String> pinnedIds) async {
    pinned.clear();
    pinned.addAll(pinnedIds);
  }

  @override
  Future<List<DesignSpecimen>> loadCustomSpecimens() async => customSaved;

  @override
  Future<void> saveCustomSpecimen(DesignSpecimen specimen) async {
    customSaved.insert(0, specimen);
  }

  @override
  Future<void> removeCustomSpecimen(String specimenId) async {
    customSaved.removeWhere((s) => s.id == specimenId);
  }

  @override
  Future<void> persistPreference(String key, String value) async {}

  @override
  Future<String?> readPreference(String key) async => null;
}

class MockProvenanceGateway implements IProvenanceGateway {
  @override
  bool isValidUrl(String url) {
    if (url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  @override
  Future<bool> canLaunchArtisanStore(String url) async => isValidUrl(url);

  @override
  Future<bool> launchArtisanStore(String url) async => true;
}

void main() {
  group('Phase 2: Deterministic Verifier Gate Tests', () {
    test('Verifier Gate 1: Visual Resolution Fidelity Assertion', () {
      // 1. High fidelity image passes
      final passResult = VisualResolutionVerifier.verify(
        width: 1200,
        height: 800,
        byteSize: 450 * 1024,
      );
      expect(passResult.isPass, true);
      expect(passResult.status, VerifierStatus.pass);

      // 2. Low-res thumbnail fails
      final failRes = VisualResolutionVerifier.verify(
        width: 400,
        height: 300,
      );
      expect(failRes.isFail, true);
      expect(failRes.telemetry.contains('fails min bound'), true);

      // 3. Oversized file (> 12MB) fails
      final failSize = VisualResolutionVerifier.verify(
        width: 2000,
        height: 1500,
        byteSize: 14 * 1024 * 1024,
      );
      expect(failSize.isFail, true);
      expect(failSize.telemetry.contains('exceeds limit'), true);
    });

    test('Verifier Gate 2: Aspect Ratio Bounds & Center-Weighted Repair', () {
      // 1. In-bound aspect ratio passes
      final passRatio = AspectRatioVerifier.verifyAndClamp(0.85);
      expect(passRatio.isPass, true);
      expect(passRatio.value, 0.85);

      // 2. Out-of-bound horizontal panorama repairs to 1.33
      final clampedPano = AspectRatioVerifier.verifyAndClamp(2.4);
      expect(clampedPano.isRepaired, true);
      expect(clampedPano.value, 1.33);

      // 3. Out-of-bound vertical banner repairs to 0.75
      final clampedBanner = AspectRatioVerifier.verifyAndClamp(0.45);
      expect(clampedBanner.isRepaired, true);
      expect(clampedBanner.value, 0.75);

      // 4. Center-weighted crop box calculation
      final crop = AspectRatioVerifier.calculateCenterWeightedCrop(
        originalWidth: 1000,
        originalHeight: 2000, // Ratio 0.5 (too tall)
      );
      expect(crop.width, 1000.0);
      expect(crop.height, closeTo(1333.33, 0.1));
      expect(crop.top, closeTo(333.33, 0.1)); // Centered offset
    });

    test('Verifier Gate 3: Crossmodal Audio-Visual Congruency Matching', () {
      // 1. Semantic keyword matching
      final darkTechMatch = CrossmodalCongruenceVerifier.matchAtmosphere(
        keywords: ['OP-1', 'synthesizer', 'dark', 'neon', 'aluminum'],
      );
      expect(darkTechMatch.value, 'rain_study');

      final terracottaMatch = CrossmodalCongruenceVerifier.matchAtmosphere(
        keywords: ['ceramic', 'mug', 'warm', 'travertine'],
      );
      expect(terracottaMatch.value, 'raw_terracotta');

      // 2. Hue Angle Congruence
      final blueSlate = CrossmodalCongruenceVerifier.matchAtmosphere(dominantHueDegrees: 215.0);
      expect(blueSlate.value, 'rain_study');

      final indigoSlate = CrossmodalCongruenceVerifier.matchAtmosphere(dominantHueDegrees: 255.0);
      expect(indigoSlate.value, 'rain_study');

      final warmClay = CrossmodalCongruenceVerifier.matchAtmosphere(dominantHueDegrees: 30.0);
      expect(warmClay.value, 'raw_terracotta');
    });
  });

  group('Phase 2: Graph 1 Atmospheric State Machine Transitions', () {
    test('State machine transitions cleanly and triggers crossfade', () async {
      final audioGateway = MockAudioGateway();
      final stateMachine = AtmosphereStateMachine(audioGateway: audioGateway);
      await stateMachine.init();

      expect(stateMachine.state.activeId, 'rain_study');
      expect(audioGateway.lastPlayedAsset, 'assets/audio/rain_study.ogg');

      // Transition to Raw Terracotta
      await stateMachine.transitionTo('raw_terracotta');
      expect(stateMachine.state.activeId, 'raw_terracotta');
      expect(stateMachine.state.displayName, 'Raw Terracotta');
      expect(stateMachine.state.backgroundColor, const Color(0xFFF5F2EB));
      expect(audioGateway.lastPlayedAsset, 'assets/audio/raw_terracotta.wav');

      // Transition back to Rain & Study
      await stateMachine.transitionTo('rain_study');
      expect(stateMachine.state.activeId, 'rain_study');
      expect(stateMachine.state.displayName, 'Rain & Study');
      expect(stateMachine.state.backgroundColor, const Color(0xFF16181D));
      expect(audioGateway.lastPlayedAsset, 'assets/audio/rain_study.ogg');
    });

    test('Conflict Gate: External Audio Active causes Silent Theme Shift', () async {
      final audioGateway = MockAudioGateway()..externalAudioActive = true;
      final stateMachine = AtmosphereStateMachine(audioGateway: audioGateway);
      await stateMachine.init();

      // Transition while external audio is active
      await stateMachine.transitionTo('raw_terracotta');
      expect(stateMachine.state.activeId, 'raw_terracotta');
      expect(stateMachine.state.isExternalAudioDetected, true);
    });
  });

  group('Phase 2: Graph 2 Ingestion & Curation Pipeline Tests', () {
    test('Pipeline rejects invalid URL', () async {
      final pipeline = SpecimenIngestionPipeline(
        storageGateway: MockStorageGateway(),
        provenanceGateway: MockProvenanceGateway(),
      );

      final result = await pipeline.ingest(
        rawUrl: 'not_a_valid_url',
        title: 'Broken Specimen',
      );

      expect(result.isSuccess, false);
      expect(result.specimen, isNull);
      expect(result.errorMessage?.contains('Invalid URL'), true);
    });

    test('Pipeline rejects low resolution images', () async {
      final pipeline = SpecimenIngestionPipeline(
        storageGateway: MockStorageGateway(),
        provenanceGateway: MockProvenanceGateway(),
      );

      final result = await pipeline.ingest(
        rawUrl: 'https://images.unsplash.com/sample_photo',
        title: 'Low Res Item',
        imageWidth: 320,
        imageHeight: 240,
      );

      expect(result.isSuccess, false);
      expect(result.errorMessage?.contains('quality requirements'), true);
    });

    test('Pipeline repairs extreme aspect ratio and commits to storage', () async {
      final storage = MockStorageGateway();
      final pipeline = SpecimenIngestionPipeline(
        storageGateway: storage,
        provenanceGateway: MockProvenanceGateway(),
      );

      final result = await pipeline.ingest(
        rawUrl: 'https://images.unsplash.com/craft_item',
        title: 'Hasami Bowl',
        maker: 'Hasami Atelier',
        estimatedUsd: 48.0,
        rawAspectRatio: 2.2, // Extreme panorama
        materials: ['Clay', 'Glaze'],
      );

      expect(result.isSuccess, true);
      expect(result.specimen != null, true);
      expect(result.specimen!.aspectRatio, 1.33); // Repaired!
      expect(result.specimen!.atmosphereTag, 'raw_terracotta'); // Auto-congruence!
      expect(storage.customSaved.length, 1);
      expect(storage.customSaved.first.id, result.specimen!.id);
    });
  });
}
