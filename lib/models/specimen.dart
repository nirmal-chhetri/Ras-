class Atmosphere {
  final String id;
  final String displayName;
  final String tagline;
  final String audioTrack;
  final String telemetryFrequency;
  final String colorTheme;

  const Atmosphere({
    required this.id,
    required this.displayName,
    required this.tagline,
    required this.audioTrack,
    required this.telemetryFrequency,
    required this.colorTheme,
  });

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
}

class DesignSpecimen {
  final String id;
  final String title;
  final String maker;
  final String studioLocation;
  final double estimatedUsd;
  final String atmosphereTag;
  final String imageUrl;
  final double aspectRatio;
  final String materialStory;
  final String provenanceUrl;
  final List<String> materials;
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
}
