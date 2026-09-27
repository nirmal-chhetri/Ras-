import 'package:flutter/foundation.dart';

/// ============================================================================
/// FILE: lib/models/specimen.dart
/// ARCHITECTURE LAYER: Core Domain Models (Phase 0 & Phase 1)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// This file defines the core, immutable domain entities that underpin the
/// entire Aether application:
///
/// 1. [Atmosphere]:
///    Represents a distinct sensory environment (or "biome") that synchronizes
///    editorial color themes, acoustic audio tracks, and telemetry frequencies.
///    The system ships with curated distinct atmospheres:
///    - 'rain_study': Slate Charcoal (reflective, contemplative, rain/focus desk)
///    - 'raw_terracotta': Warm Travertine (sun-drenched clay, lo-fi acoustic tape)
///
/// 2. [DesignSpecimen]:
///    Represents an artisanal, non-mass-produced design artifact. Replaces
///    hyper-commercial "products" with mindfully cataloged "specimens". Each
///    specimen maintains strict metadata regarding its maker, provenance URL,
///    studio geographic location, materiality narrative, and a pre-verified
///    aspect ratio clamped within the deterministic bounds [0.75, 1.33].
///
/// EXTENSION GUIDE FOR FUTURE DEVELOPERS:
/// - To add a new Atmosphere:
///   1. Append a new entry to DATA_CATALOG.json under "atmospheres".
///   2. Add a corresponding [AetherTheme] definition in `lib/core/theme.dart`.
///   3. Place an offline audio loop (.ogg or .wav) in `assets/audio/`.
///   4. Update [AetherTheme.fromAtmosphereId] and [CrossmodalCongruenceVerifier].
///
/// - To add fields to [DesignSpecimen]:
///   1. Add the immutable `final` field.
///   2. Update the constructor, [fromJson], [toJson], and [copyWith].
///   3. Ensure [SpecimenIngestionPipeline] and [CatalogRepository] pass the field.
/// ============================================================================

/// Represents an environmental sensory mood state containing color, audio,
/// and telemetry metadata.
@immutable
class Atmosphere {
  /// Unique identifier (e.g. 'rain_study', 'raw_terracotta').
  final String id;

  /// Human-readable title displayed in the broadsheet UI and selector popup.
  final String displayName;

  /// Evocative editorial headline describing the mood and living philosophy.
  final String tagline;

  /// Relative path to the local audio loop bundled in Flutter assets
  /// (e.g. 'assets/audio/rain_study.ogg').
  final String audioTrack;

  /// Tabular frequency badge rendered in Space Grotesk tabular font
  /// (e.g. '800Hz–4kHz Rain Resonance').
  final String telemetryFrequency;

  /// Identifier mapping directly to [AetherTheme.id] for dynamic skinning.
  final String colorTheme;

  const Atmosphere({
    required this.id,
    required this.displayName,
    required this.tagline,
    required this.audioTrack,
    required this.telemetryFrequency,
    required this.colorTheme,
  });

  /// Factory constructor to deserialize an [Atmosphere] from standard JSON.
  /// Used by [SharedPreferencesStorageGateway] when reading DATA_CATALOG.json.
  factory Atmosphere.fromJson(Map<String, dynamic> json) {
    return Atmosphere(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      tagline: json['tagline'] as String,
      audioTrack: json['audioTrack'] as String,
      telemetryFrequency: json['telemetryFrequency'] as String,
      colorTheme: json['colorTheme'] as String,
    );
  }

  /// Serializes the atmosphere instance into a map structure for cache persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'tagline': tagline,
      'audioTrack': audioTrack,
      'telemetryFrequency': telemetryFrequency,
      'colorTheme': colorTheme,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Atmosphere && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents an artisanal craft piece curated within the Sanctuary.
///
/// Adheres strictly to the Slow-Commerce manifesto:
/// - No commercial "discount" or "sale" attributes.
/// - Prioritizes material integrity, provenance, and maker transparency.
/// - Requires pre-calculated or clamped [aspectRatio] to guarantee zero layout
///   jank or jumping in the staggered masonry feed.
@immutable
class DesignSpecimen {
  /// Unique identifier (e.g. 'specimen_01' or timestamped 'ingested_...').
  final String id;

  /// Editorial title of the design piece (e.g. 'Acoustic Terracotta Speaker').
  final String title;

  /// Independent artisan, designer, or studio workshop behind the object.
  final String maker;

  /// City and country where the craft piece was born (e.g. 'Copenhagen, Denmark').
  final String studioLocation;

  /// Estimated valuation in USD (avoids deceptive discount strikes).
  final double estimatedUsd;

  /// Associated atmosphere tag ('rain_study', 'raw_terracotta')
  /// assigned either manually or deterministically via [CrossmodalCongruenceVerifier].
  final String atmosphereTag;

  /// High-resolution image CDN endpoint (Unsplash or artisan atelier media).
  final String imageUrl;

  /// Aspect ratio (width / height) clamped strictly to [0.75, 1.33] to prevent
  /// runaway extreme vertical or horizontal masonry tiles.
  final double aspectRatio;

  /// Deep contextual editorial narrative explaining the physical materials,
  /// craftsmanship techniques, and philosophy of creation.
  final String materialStory;

  /// Validated HTTP/HTTPS web link redirecting to the artisan's independent
  /// online atelier via the Slow-Commerce Decompression Gate.
  final String provenanceUrl;

  /// Distinct list of tangible material tags (e.g. ['Glazed Clay', 'Walnut Wood']).
  final List<String> materials;

  /// Indicates whether the active user has pinned this specimen to their
  /// personal Studio Moodboard.
  final bool isUserPinned;

  const DesignSpecimen({
    required this.id,
    required this.title,
    required this.maker,
    required this.studioLocation,
    required this.estimatedUsd,
    required this.atmosphereTag,
    required this.imageUrl,
    required this.aspectRatio,
    required this.materialStory,
    required this.provenanceUrl,
    required this.materials,
    this.isUserPinned = false,
  });

  /// Factory deserializer converting raw catalog JSON into a strongly typed [DesignSpecimen].
  /// Handles numeric type conversion safely for [estimatedUsd] and [aspectRatio].
  factory DesignSpecimen.fromJson(Map<String, dynamic> json) {
    return DesignSpecimen(
      id: json['id'] as String,
      title: json['title'] as String,
      maker: json['maker'] as String,
      studioLocation: json['studioLocation'] as String,
      estimatedUsd: (json['estimatedUsd'] as num).toDouble(),
      atmosphereTag: json['atmosphereTag'] as String,
      imageUrl: json['imageUrl'] as String,
      aspectRatio: (json['aspectRatio'] as num).toDouble(),
      materialStory: json['materialStory'] as String,
      provenanceUrl: json['provenanceUrl'] as String,
      materials: (json['materials'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isUserPinned: json['isUserPinned'] as bool? ?? false,
    );
  }

  /// Serializes the specimen for persistent local storage in [SharedPreferencesStorageGateway].
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'maker': maker,
      'studioLocation': studioLocation,
      'estimatedUsd': estimatedUsd,
      'atmosphereTag': atmosphereTag,
      'imageUrl': imageUrl,
      'aspectRatio': aspectRatio,
      'materialStory': materialStory,
      'provenanceUrl': provenanceUrl,
      'materials': materials,
      'isUserPinned': isUserPinned,
    };
  }

  /// Creates an immutable copy of the specimen with selective fields updated.
  /// Frequently used when toggling [isUserPinned] or applying aspect ratio repair.
  DesignSpecimen copyWith({
    String? id,
    String? title,
    String? maker,
    String? studioLocation,
    double? estimatedUsd,
    String? atmosphereTag,
    String? imageUrl,
    double? aspectRatio,
    String? materialStory,
    String? provenanceUrl,
    List<String>? materials,
    bool? isUserPinned,
  }) {
    return DesignSpecimen(
      id: id ?? this.id,
      title: title ?? this.title,
      maker: maker ?? this.maker,
      studioLocation: studioLocation ?? this.studioLocation,
      estimatedUsd: estimatedUsd ?? this.estimatedUsd,
      atmosphereTag: atmosphereTag ?? this.atmosphereTag,
      imageUrl: imageUrl ?? this.imageUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      materialStory: materialStory ?? this.materialStory,
      provenanceUrl: provenanceUrl ?? this.provenanceUrl,
      materials: materials ?? this.materials,
      isUserPinned: isUserPinned ?? this.isUserPinned,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DesignSpecimen &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
