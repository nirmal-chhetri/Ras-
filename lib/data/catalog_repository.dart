import '../models/specimen.dart';
import '../core/gateways/storage_gateway.dart';
import '../core/verifiers/deterministic_verifiers.dart';

class CatalogRepository {
  final IStorageGateway _storageGateway;

  List<Atmosphere> _atmospheres = [];
  List<DesignSpecimen> _specimens = [];
  final Set<String> _pinnedIds = {};

  List<Atmosphere> get atmospheres => List.unmodifiable(_atmospheres);
  List<DesignSpecimen> get specimens => List.unmodifiable(_specimens);
  List<DesignSpecimen> get pinnedSpecimens =>
      _specimens.where((s) => _pinnedIds.contains(s.id)).toList();
  IStorageGateway get storageGateway => _storageGateway;

  CatalogRepository({IStorageGateway? storageGateway})
      : _storageGateway = storageGateway ?? SharedPreferencesStorageGateway();

  Future<void> init() async {
    await _loadData();
  }

  void clearAllPins() {
    _pinnedIds.clear();
    _specimens = _specimens.map((s) => s.copyWith(isUserPinned: false)).toList();
    _storageGateway.persistPinnedIds(_pinnedIds);
  }

  Future<void> _loadData() async {
    // 1. Load saved pinned IDs
    final savedPins = await _storageGateway.loadPinnedIds();
    _pinnedIds.clear();
    _pinnedIds.addAll(savedPins);

    // 2. Load atmospheres
    _atmospheres = await _storageGateway.loadAtmospheres();

    // 3. Load base specimens
    final baseSpecimens = await _storageGateway.loadBaseCatalog();

    // 4. Load user custom curated specimens
    final customSpecimens = await _storageGateway.loadCustomSpecimens();

    // 5. Apply Deterministic Verifier Gate 2 (Aspect Ratio Clamping)
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

  // Verifier Gate 2: Enforce Aspect Ratio Bounds [0.75, 1.33]
  double _clampAspectRatio(double rawRatio) {
    if (rawRatio < 0.75) return 0.75;
    if (rawRatio > 1.33) return 1.33;
    return rawRatio;
  }

  List<DesignSpecimen> getByAtmosphere(String atmosphereId) {
    return _specimens
        .where((s) => s.atmosphereTag == atmosphereId)
        .toList();
  }

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
