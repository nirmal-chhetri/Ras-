import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/specimen.dart';

class CatalogRepository {
  List<Atmosphere> _atmospheres = [];
  List<DesignSpecimen> _specimens = [];
  final Set<String> _pinnedIds = {};

  List<Atmosphere> get atmospheres => List.unmodifiable(_atmospheres);
  List<DesignSpecimen> get specimens => List.unmodifiable(_specimens);
  List<DesignSpecimen> get pinnedSpecimens =>
      _specimens.where((s) => _pinnedIds.contains(s.id)).toList();

  static const String _pinnedStorageKey = 'aether_pinned_specimen_ids';

  Future<void> init() async {
    await _loadSavedPins();
    await _loadCatalogJson();
  }

  Future<void> _loadSavedPins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_pinnedStorageKey) ?? [];
      _pinnedIds.addAll(saved);
    } catch (_) {
      // Memory fallback if storage unavailable
    }
  }

  Future<void> _persistPins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_pinnedStorageKey, _pinnedIds.toList());
    } catch (_) {}
  }

  Future<void> _loadCatalogJson() async {
    try {
      final jsonStr = await rootBundle.loadString('DATA_CATALOG.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;

      _atmospheres = (data['atmospheres'] as List<dynamic>)
          .map((a) => Atmosphere.fromJson(a as Map<String, dynamic>))
          .toList();

      final rawSpecimens = (data['specimens'] as List<dynamic>)
          .map((s) => DesignSpecimen.fromJson(s as Map<String, dynamic>))
          .toList();

      // Apply Deterministic Aspect Ratio Clamping Verifier
      _specimens = rawSpecimens.map((specimen) {
        final clampedRatio = _clampAspectRatio(specimen.aspectRatio);
        final isPinned = _pinnedIds.contains(specimen.id);
        return specimen.copyWith(
          aspectRatio: clampedRatio,
          isUserPinned: isPinned,
        );
      }).toList();
    } catch (e) {
      // Fallback seed if asset loading fails
      _specimens = [];
    }
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
    _persistPins();
  }

  void addCustomSpecimen(DesignSpecimen specimen) {
    final clamped = specimen.copyWith(
      aspectRatio: _clampAspectRatio(specimen.aspectRatio),
      isUserPinned: true,
    );
    _specimens.insert(0, clamped);
    _pinnedIds.add(clamped.id);
    _persistPins();
  }
}
