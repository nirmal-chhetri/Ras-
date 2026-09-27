import '../models/specimen.dart';
import '../core/gateways/storage_gateway.dart';
import '../core/verifiers/deterministic_verifiers.dart';

/// ============================================================================
/// FILE: lib/data/catalog_repository.dart
/// ARCHITECTURE LAYER: Data Repository Layer (Phase 1, 3 & 6)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// [CatalogRepository] serves as the single source of truth for all specimen data,
/// atmospheric biomes, and user curation states.
///
/// CORE RESPONSIBILITIES:
/// 1. Unified Catalog Aggregation:
///    Combines baseline artisanal specimens from [DATA_CATALOG.json] with user-clipped
///    custom specimens saved in [IStorageGateway].
///
/// 2. Deterministic Aspect Ratio Clamping:
///    During data loading ([_loadData]), every single specimen is passed through
///    [AspectRatioVerifier.verifyAndClamp] to guarantee that no un-clamped aspect
///    ratio enters the presentation layer or masonry grid.
///
/// 3. Pin State Synchronization:
///    Maintains an in-memory set of pinned IDs and persists changes to
///    [IStorageGateway.persistPinnedIds] immediately upon toggle.
///
/// 4. Sub-filtering by Atmosphere:
///    Provides fast, in-memory filtering of specimens by atmosphere ID
///    ('rain_study', 'tokyo_nocturne', 'raw_terracotta') via [getByAtmosphere].
///
/// EXTENSION GUIDE FOR FUTURE DEVELOPERS:
/// - To add pagination or infinite scrolling:
///   Add `int page` and `int pageSize` parameters to [getByAtmosphere] and slice
///   the internal list accordingly.
/// - To add full-text keyword search:
///   Add a method `List<DesignSpecimen> search(String query)` filtering against
///   title, maker, and materials.
/// ============================================================================

/// Repository managing atmospheres, specimens, and curation pin states.
class CatalogRepository {
  final IStorageGateway _storageGateway;

  List<Atmosphere> _atmospheres = [];
  List<DesignSpecimen> _specimens = [];
  final Set<String> _pinnedIds = {};

  /// Immutable list of available atmospheric biomes.
  List<Atmosphere> get atmospheres => List.unmodifiable(_atmospheres);

  /// Immutable list of all verified specimens (baseline + user custom).
  List<DesignSpecimen> get specimens => List.unmodifiable(_specimens);

  /// Filtered list containing only specimens currently pinned to the user's Studio.
  List<DesignSpecimen> get pinnedSpecimens =>
      _specimens.where((s) => _pinnedIds.contains(s.id)).toList();

  /// Access to the underlying storage gateway (useful for dependency injection in tests).
  IStorageGateway get storageGateway => _storageGateway;

  /// Creates a repository, defaulting to [SharedPreferencesStorageGateway] if not injected.
  CatalogRepository({IStorageGateway? storageGateway})
      : _storageGateway = storageGateway ?? SharedPreferencesStorageGateway();

  /// Asynchronously loads baseline data, saved pins, and custom items into memory.
  Future<void> init() async {
    await _loadData();
  }

  /// Clears all pinned specimens from the studio canvas and updates persistent storage.
  void clearAllPins() {
    _pinnedIds.clear();
    _specimens =
        _specimens.map((s) => s.copyWith(isUserPinned: false)).toList();
    _storageGateway.persistPinnedIds(_pinnedIds);
  }

  /// Internal loader reading from storage and executing Verifier Gate 2.
  Future<void> _loadData() async {
    // 1. Load saved pinned IDs
    final savedPins = await _storageGateway.loadPinnedIds();
    _pinnedIds.clear();
    _pinnedIds.addAll(savedPins);

    // 2. Load atmospheres from bundled data
    _atmospheres = await _storageGateway.loadAtmospheres();

    // 3. Load baseline curated specimens
    final baseSpecimens = await _storageGateway.loadBaseCatalog();

    // 4. Load user custom clipped specimens
    final customSpecimens = await _storageGateway.loadCustomSpecimens();

    // 5. Apply Deterministic Verifier Gate 2 (Aspect Ratio Clamping [0.75, 1.33])
    final allRaw = [...customSpecimens, ...baseSpecimens];
    _specimens = allRaw.map((specimen) {
      final verified = AspectRatioVerifier.verifyAndClamp(specimen.aspectRatio);
      final isPinned = _pinnedIds.contains(specimen.id);
      return specimen.copyWith(
        aspectRatio: verified.value,
        isUserPinned: isPinned,
      );
    }).toList();
  }

  /// Helper to clamp aspect ratio within bounds [0.75, 1.33].
  double _clampAspectRatio(double rawRatio) {
    if (rawRatio < 0.75) return 0.75;
    if (rawRatio > 1.33) return 1.33;
    return rawRatio;
  }

  /// Returns specimens belonging to a specific atmosphere biome.
  List<DesignSpecimen> getByAtmosphere(String atmosphereId) {
    return _specimens
        .where((s) => s.atmosphereTag == atmosphereId)
        .toList();
  }

  /// Toggles the pinned bookmark state for a given specimen ID.
  /// Automatically persists the change to [IStorageGateway].
  void togglePin(String id) {
    if (_pinnedIds.contains(id)) {
      _pinnedIds.remove(id);
    } else {
      _pinnedIds.add(id);
    }
    _specimens = _specimens.map((s) {
      if (s.id == id) {
        return s.copyWith(isUserPinned: _pinnedIds.contains(id));
      }
      return s;
    }).toList();
    _storageGateway.persistPinnedIds(_pinnedIds);
  }

  /// Adds a newly ingested user specimen to the top of the feed and pins it.
  void addCustomSpecimen(DesignSpecimen specimen) {
    final clamped = specimen.copyWith(
      aspectRatio: _clampAspectRatio(specimen.aspectRatio),
      isUserPinned: true,
    );
    _specimens.insert(0, clamped);
    _pinnedIds.add(clamped.id);
    _storageGateway.persistPinnedIds(_pinnedIds);
    _storageGateway.saveCustomSpecimen(clamped);
  }
}
