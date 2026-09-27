import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/specimen.dart';

/// Semantic Tool Gateway 2: Storage & Curation Gateway
/// Isolates persistence, cache storage, and catalog loading from UI.
abstract class IStorageGateway {
  Future<List<Atmosphere>> loadAtmospheres();
  Future<List<DesignSpecimen>> loadBaseCatalog();
  Future<Set<String>> loadPinnedIds();
  Future<void> persistPinnedIds(Set<String> pinnedIds);
  Future<List<DesignSpecimen>> loadCustomSpecimens();
  Future<void> saveCustomSpecimen(DesignSpecimen specimen);
  Future<void> removeCustomSpecimen(String specimenId);
  Future<void> persistPreference(String key, String value);
  Future<String?> readPreference(String key);
}

class SharedPreferencesStorageGateway implements IStorageGateway {
  static const String _pinnedStorageKey = 'aether_pinned_specimen_ids';
  static const String _customSpecimensKey = 'aether_custom_specimens_json';

  @override
  Future<List<Atmosphere>> loadAtmospheres() async {
    try {
      final jsonStr = await rootBundle.loadString('DATA_CATALOG.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (data['atmospheres'] as List<dynamic>?) ?? [];
      return list.map((a) => Atmosphere.fromJson(a as Map<String, dynamic>)).toList();
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
      return list.map((s) => DesignSpecimen.fromJson(s as Map<String, dynamic>)).toList();
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
      return decoded.map((e) => DesignSpecimen.fromJson(e as Map<String, dynamic>)).toList();
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
