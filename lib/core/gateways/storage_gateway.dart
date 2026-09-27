import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/specimen.dart';

/// ============================================================================
/// FILE: lib/core/gateways/storage_gateway.dart
/// ARCHITECTURE LAYER: Semantic Tool Gateway 2 — Storage & Curation (Phase 2 & 6)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// [IStorageGateway] abstracts all data persistence, cache retrieval, and initial
/// catalog loading from the user interface and presentation layers.
///
/// It isolates:
/// 1. Bundled Catalog Ingestion:
///    Reads the immutable [DATA_CATALOG.json] asset packaged with the app.
///
/// 2. User Pin Persistence:
///    Saves and restores the set of pinned specimen IDs in the user's Studio.
///
/// 3. Custom Specimen Curation:
///    Allows users to clip new artisanal artifacts into their studio via
///    [SpecimenIngestionPipeline] and persists them across app cold restarts.
///
/// 4. Key-Value User Preferences:
///    Provides generic key-value storage for theme choices or volume preferences.
///
/// [SharedPreferencesStorageGateway] provides the production implementation
/// backed by [SharedPreferences] and [rootBundle].
///
/// EXTENSION GUIDE FOR FUTURE DEVELOPERS:
/// - To swap local persistence with SQLite, Hive, or Cloud Supabase sync:
///   Create a new class implementing [IStorageGateway] (e.g. `SupabaseStorageGateway`)
///   and pass it to [CatalogRepository].
/// ============================================================================

/// Contract defining persistence, catalog loading, and studio curation storage.
abstract class IStorageGateway {
  /// Loads atmospheric biome definitions from the catalog.
  Future<List<Atmosphere>> loadAtmospheres();

  /// Loads baseline artisanal specimens from the bundled catalog.
  Future<List<DesignSpecimen>> loadBaseCatalog();

  /// Loads the set of pinned specimen IDs saved in local persistent storage.
  Future<Set<String>> loadPinnedIds();

  /// Commits the set of pinned specimen IDs to persistent storage.
  Future<void> persistPinnedIds(Set<String> pinnedIds);

  /// Loads custom user-clipped specimens from local storage.
  Future<List<DesignSpecimen>> loadCustomSpecimens();

  /// Saves a newly ingested user specimen into local persistent storage.
  Future<void> saveCustomSpecimen(DesignSpecimen specimen);

  /// Deletes a custom specimen from local persistent storage.
  Future<void> removeCustomSpecimen(String specimenId);

  /// Saves a generic key-value preference string.
  Future<void> persistPreference(String key, String value);

  /// Retrieves a generic key-value preference string.
  Future<String?> readPreference(String key);
}

/// Production implementation of [IStorageGateway] using [SharedPreferences] and [rootBundle].
class SharedPreferencesStorageGateway implements IStorageGateway {
  /// Storage key for the list of pinned specimen IDs.
  static const String _pinnedStorageKey = 'aether_pinned_specimen_ids';

  /// Storage key for serialized custom user-clipped specimens.
  static const String _customSpecimensKey = 'aether_custom_specimens_json';

  @override
  Future<List<Atmosphere>> loadAtmospheres() async {
    try {
      final jsonStr = await rootBundle.loadString('DATA_CATALOG.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (data['atmospheres'] as List<dynamic>?) ?? [];
      return list
          .map((a) => Atmosphere.fromJson(a as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<DesignSpecimen>> loadBaseCatalog() async {
    try {
      final jsonStr = await rootBundle.loadString('DATA_CATALOG.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (data['specimens'] as List<dynamic>?) ?? [];
      return list
          .map((s) => DesignSpecimen.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Set<String>> loadPinnedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_pinnedStorageKey) ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> persistPinnedIds(Set<String> pinnedIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_pinnedStorageKey, pinnedIds.toList());
    } catch (_) {}
  }

  @override
  Future<List<DesignSpecimen>> loadCustomSpecimens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_customSpecimensKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((e) => DesignSpecimen.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveCustomSpecimen(DesignSpecimen specimen) async {
    try {
      final existing = await loadCustomSpecimens();
      existing.removeWhere((s) => s.id == specimen.id);
      existing.insert(0, specimen);

      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(existing.map((e) => e.toJson()).toList());
      await prefs.setString(_customSpecimensKey, encoded);
    } catch (_) {}
  }

  @override
  Future<void> removeCustomSpecimen(String specimenId) async {
    try {
      final existing = await loadCustomSpecimens();
      existing.removeWhere((s) => s.id == specimenId);

      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(existing.map((e) => e.toJson()).toList());
      await prefs.setString(_customSpecimensKey, encoded);
    } catch (_) {}
  }

  @override
  Future<void> persistPreference(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {}
  }

  @override
  Future<String?> readPreference(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }
}
