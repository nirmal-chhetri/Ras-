import '../../models/specimen.dart';
import '../gateways/storage_gateway.dart';
import '../gateways/provenance_gateway.dart';
import '../verifiers/deterministic_verifiers.dart';

/// ============================================================================
/// FILE: lib/core/pipelines/ingestion_pipeline.dart
/// ARCHITECTURE LAYER: Graph 2 — Specimen Ingestion & Curation Pipeline (Phase 2 & 6)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// [SpecimenIngestionPipeline] implements Graph 2 as specified in GRAPH_WORKFLOWS.md.
/// It coordinates the complete life cycle of clipping and curating a new artisanal
/// artifact from a raw web link into the user's personal Studio Moodboard.
///
/// PIPELINE WORKFLOW (7 NODES):
/// 1. Node 1: Sanitization & URL Gateway Assertion
///    Validates that the provided link is a valid HTTP/HTTPS endpoint via
///    [IProvenanceGateway.isValidUrl]. Rejects invalid or malicious strings.
///
/// 2. Node 2 & 3: Verifier Gate 1 — Fidelity Assertion
///    If pixel dimensions are available, executes [VisualResolutionVerifier.verify]
///    to assert $\min(w,h) \ge 600\text{px}$ and $size \le 12\text{MB}$.
///
/// 3. Node 4: Verifier Gate 2 — Masonry Integrity Bounds
///    Clamps [rawAspectRatio] to $[0.75, 1.33]$ using [AspectRatioVerifier.verifyAndClamp].
///
/// 4. Node 5: Verifier Gate 3 — Crossmodal Congruence Matching
///    Scans title, maker, and materials through [CrossmodalCongruenceVerifier.matchAtmosphere]
///    to assign the specimen to the most congruent atmospheric biome.
///
/// 5. Node 6: Domain Model Construction
///    Assembles a complete, immutable [DesignSpecimen] with user-pinned status.
///
/// 6. Node 7: Persistent Commit
///    Commits the validated specimen into [IStorageGateway.saveCustomSpecimen]
///    so it survives app restarts.
///
/// EXTENSION GUIDE FOR FUTURE DEVELOPERS:
/// - To add automated web scraping / OpenGraph metadata extraction:
///   Insert an OpenGraph extraction node before Node 2 to fetch image URLs
///   and titles automatically from raw artisan shop URLs.
/// ============================================================================

/// Encapsulates the execution result and step-by-step telemetry of an ingestion run.
class IngestionResult {
  /// True if the specimen passed all invariant checks and committed to storage.
  final bool isSuccess;

  /// The resulting domain specimen (null if rejected).
  final DesignSpecimen? specimen;

  /// Chronological audit log of decisions made at each pipeline node.
  final List<String> telemetryLogs;

  /// Human-friendly error description if rejected.
  final String? errorMessage;

  const IngestionResult({
    required this.isSuccess,
    this.specimen,
    required this.telemetryLogs,
    this.errorMessage,
  });
}

/// Pipeline coordinator that ingests raw user inputs through deterministic verifiers
/// into the persistent catalog.
class SpecimenIngestionPipeline {
  final IStorageGateway _storageGateway;
  final IProvenanceGateway _provenanceGateway;

  SpecimenIngestionPipeline({
    required IStorageGateway storageGateway,
    required IProvenanceGateway provenanceGateway,
  })  : _storageGateway = storageGateway,
        _provenanceGateway = provenanceGateway;

  /// Ingests a new specimen candidate through the 7-node pipeline.
  ///
  /// Parameters:
  /// - [rawUrl]: Raw web link to the image or artisan product page.
  /// - [title]: Editorial title given to the specimen.
  /// - [maker]: Optional artisan or craft workshop name.
  /// - [studioLocation]: Optional city/region of the maker.
  /// - [estimatedUsd]: Optional estimated price valuation.
  /// - [rawAspectRatio]: Raw aspect ratio if known prior to download.
  /// - [imageWidth]: Image width in pixels for fidelity assertion.
  /// - [imageHeight]: Image height in pixels for fidelity assertion.
  /// - [materials]: Optional material tags (e.g. ['Walnut', 'Cast Iron']).
  /// - [materialStory]: Optional contextual narrative.
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
      maker: (maker == null || maker.trim().isEmpty)
          ? 'Independent Artisan'
          : maker.trim(),
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
      materials:
          (materials == null || materials.isEmpty) ? ['Artisan Craft'] : materials,
      isUserPinned: true,
    );

    // Node 7: Commit to Storage Gateway
    await _storageGateway.saveCustomSpecimen(newSpecimen);
    telemetry.add(
        '[COMMIT] Specimen committed to Storage Gateway (${newSpecimen.id})');

    return IngestionResult(
      isSuccess: true,
      specimen: newSpecimen,
      telemetryLogs: telemetry,
    );
  }
}
