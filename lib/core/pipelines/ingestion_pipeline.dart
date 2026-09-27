import '../../models/specimen.dart';
import '../gateways/storage_gateway.dart';
import '../gateways/provenance_gateway.dart';
import '../verifiers/deterministic_verifiers.dart';

class IngestionResult {
  final bool isSuccess;
  final DesignSpecimen? specimen;
  final List<String> telemetryLogs;
  final String? errorMessage;

  const IngestionResult({
    required this.isSuccess,
    this.specimen,
    required this.telemetryLogs,
    this.errorMessage,
  });
}

/// Graph 2: Specimen Ingestion & Curation Pipeline
/// Processes raw user inputs, verifies invariants, and commits to storage.
class SpecimenIngestionPipeline {
  final IStorageGateway _storageGateway;
  final IProvenanceGateway _provenanceGateway;

  SpecimenIngestionPipeline({
    required IStorageGateway storageGateway,
    required IProvenanceGateway provenanceGateway,
  })  : _storageGateway = storageGateway,
        _provenanceGateway = provenanceGateway;

  Future<IngestionResult> ingest({
    required String rawUrl,
    required String title,
    String? maker,
    String? studioLocation,
    double? estimatedUsd,
    double? rawAspectRatio,
    int? imageWidth,
    int? imageHeight,
    List<String>? materials,
    String? materialStory,
  }) async {
    final telemetry = <String>[];

    // Node 1: Gateway Sanitization & URL Validation
    final cleanUrl = rawUrl.trim();
    if (!_provenanceGateway.isValidUrl(cleanUrl)) {
      return IngestionResult(
        isSuccess: false,
        telemetryLogs: ['[REJECT] Invalid URL format: $cleanUrl'],
        errorMessage: 'Invalid URL. Please provide a valid HTTP/HTTPS link.',
      );
    }
    telemetry.add('[GATEWAY] URL format verified: $cleanUrl');

    // Node 2 & 3: Verifier Gate 1 - Fidelity Assertion (if dimensions provided)
    if (imageWidth != null && imageHeight != null) {
      final resResult = VisualResolutionVerifier.verify(
        width: imageWidth,
        height: imageHeight,
      );
      telemetry.add('[VERIFIER 1] ${resResult.telemetry}');
      if (resResult.isFail) {
        return IngestionResult(
          isSuccess: false,
          telemetryLogs: telemetry,
          errorMessage: 'Image does not meet quality requirements (min 600px).',
        );
      }
    }

    // Node 4: Verifier Gate 2 - Masonry Integrity Bounds [0.75, 1.33]
    final arResult = AspectRatioVerifier.verifyAndClamp(rawAspectRatio ?? 1.0);
    final clampedRatio = arResult.value;
    telemetry.add('[VERIFIER 2] ${arResult.telemetry}');

    // Node 5: Verifier Gate 3 - Crossmodal Congruence Match
    final combinedKeywords = <String>[
      title,
      maker ?? '',
      ...(materials ?? []),
      materialStory ?? '',
    ];
    final congruenceResult = CrossmodalCongruenceVerifier.matchAtmosphere(
      keywords: combinedKeywords,
      defaultFallback: 'rain_study',
    );
    final assignedAtmosphere = congruenceResult.value;
    telemetry.add('[VERIFIER 3] ${congruenceResult.telemetry}');

    // Node 6: Construct Domain Specimen
    final newSpecimen = DesignSpecimen(
      id: 'ingested_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'Curated Specimen' : title.trim(),
      maker: (maker == null || maker.trim().isEmpty) ? 'Independent Artisan' : maker.trim(),
      studioLocation: (studioLocation == null || studioLocation.trim().isEmpty)
          ? 'Artisan Atelier'
          : studioLocation.trim(),
      estimatedUsd: estimatedUsd ?? 150.0,
      atmosphereTag: assignedAtmosphere,
      imageUrl: cleanUrl,
      aspectRatio: clampedRatio,
      materialStory: (materialStory == null || materialStory.trim().isEmpty)
          ? 'Mindfully selected artisanal piece curated directly into personal studio.'
          : materialStory.trim(),
      provenanceUrl: cleanUrl,
      materials: (materials == null || materials.isEmpty) ? ['Artisan Craft'] : materials,
      isUserPinned: true,
    );

    // Node 7: Commit to Storage Gateway
    await _storageGateway.saveCustomSpecimen(newSpecimen);
    telemetry.add('[COMMIT] Specimen committed to Storage Gateway (${newSpecimen.id})');

    return IngestionResult(
      isSuccess: true,
      specimen: newSpecimen,
      telemetryLogs: telemetry,
    );
  }
}
