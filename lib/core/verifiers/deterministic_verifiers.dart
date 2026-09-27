import 'dart:math' as math;

/// Verifier Decision Outcomes
enum VerifierStatus { pass, repair, fail }

class VerifierResult<T> {
  final VerifierStatus status;
  final T value;
  final String telemetry;

  const VerifierResult({
    required this.status,
    required this.value,
    required this.telemetry,
  });

  bool get isPass => status == VerifierStatus.pass;
  bool get isRepaired => status == VerifierStatus.repair;
  bool get isFail => status == VerifierStatus.fail;
}

/// Verifier Gate 1: Visual Resolution (Fidelity Assertion)
/// V_res(img) = PASS if min(w, h) >= 600 && byteSize <= 12MB
class VisualResolutionVerifier {
  static const int minDimensionPixels = 600;
  static const int maxByteSize = 12 * 1024 * 1024; // 12 MB

  static VerifierResult<bool> verify({
    required int width,
    required int height,
    int? byteSize,
  }) {
    final minDim = math.min(width, height);
    if (minDim < minDimensionPixels) {
      return VerifierResult(
        status: VerifierStatus.fail,
        value: false,
        telemetry: 'Resolution $width x $height fails min bound ($minDimensionPixels px).',
      );
    }

    if (byteSize != null && byteSize > maxByteSize) {
      return VerifierResult(
        status: VerifierStatus.fail,
        value: false,
        telemetry: 'Asset size ${(byteSize / (1024 * 1024)).toStringAsFixed(1)}MB exceeds limit (12MB).',
      );
    }

    return VerifierResult(
      status: VerifierStatus.pass,
      value: true,
      telemetry: 'Fidelity assertion verified: $width x $height (${byteSize ?? 0} bytes).',
    );
  }
}

/// Verifier Gate 2: Aspect Ratio Bounds (Masonry Integrity)
/// V_ar(ratio) = PASS if 0.75 <= ratio <= 1.33, otherwise REPAIR
class AspectRatioVerifier {
  static const double minBound = 0.75;
  static const double maxBound = 1.33;

  static VerifierResult<double> verifyAndClamp(double rawRatio) {
    if (rawRatio.isNaN || rawRatio.isInfinite || rawRatio <= 0) {
      return const VerifierResult(
        status: VerifierStatus.repair,
        value: 1.0,
        telemetry: 'Invalid raw aspect ratio repaired to 1.0 golden square.',
      );
    }

    if (rawRatio < minBound) {
      return VerifierResult(
        status: VerifierStatus.repair,
        value: minBound,
        telemetry: 'Extreme vertical ratio $rawRatio clamped to $minBound.',
      );
    }

    if (rawRatio > maxBound) {
      return VerifierResult(
        status: VerifierStatus.repair,
        value: maxBound,
        telemetry: 'Extreme horizontal ratio $rawRatio clamped to $maxBound.',
      );
    }

    return VerifierResult(
      status: VerifierStatus.pass,
      value: rawRatio,
      telemetry: 'Aspect ratio $rawRatio within masonry bounds [$minBound, $maxBound].',
    );
  }

  /// Calculates center-weighted crop box dimensions
  static math.Rectangle<double> calculateCenterWeightedCrop({
    required double originalWidth,
    required double originalHeight,
  }) {
    final rawRatio = originalWidth / originalHeight;

    double targetWidth = originalWidth;
    double targetHeight = originalHeight;

    if (rawRatio < minBound) {
      // Too tall: crop height
      targetHeight = originalWidth / minBound;
    } else if (rawRatio > maxBound) {
      // Too wide: crop width
      targetWidth = originalHeight * maxBound;
    }

    final offsetX = (originalWidth - targetWidth) / 2.0;
    final offsetY = (originalHeight - targetHeight) / 2.0;

    return math.Rectangle(offsetX, offsetY, targetWidth, targetHeight);
  }
}

/// Verifier Gate 3: Crossmodal Audio-Visual Congruency
/// V_congruence(img, Atmos) matches hue / semantic palette tokens to atmospheric states
class CrossmodalCongruenceVerifier {
  // Hue angle benchmarks for each atmosphere
  static const double rainStudyHue = 210.0;    // Slate blue/charcoal
  static const double tokyoNocturneHue = 250.0;// Deep obsidian/neon indigo
  static const double rawTerracottaHue = 25.0; // Warm clay/travertine

  static VerifierResult<String> matchAtmosphere({
    double? dominantHueDegrees,
    List<String>? keywords,
    String defaultFallback = 'rain_study',
  }) {
    // 1. Keyword semantic scoring
    if (keywords != null && keywords.isNotEmpty) {
      final text = keywords.join(' ').toLowerCase();

      int rainScore = 0;
      int tokyoScore = 0;
      int terracottaScore = 0;

      for (final kw in ['rain', 'slate', 'charcoal', 'paper', 'wood', 'cast iron', 'lamp', 'desk']) {
        if (text.contains(kw)) rainScore += 2;
      }
      for (final kw in ['tokyo', 'neon', 'obsidian', 'dark', 'oled', 'synth', 'metal', 'keyboard', 'headphone']) {
        if (text.contains(kw)) tokyoScore += 2;
      }
      for (final kw in ['terracotta', 'travertine', 'ceramic', 'mug', 'stone', 'lounge', 'warm', 'clay', 'beech']) {
        if (text.contains(kw)) terracottaScore += 2;
      }

      if (tokyoScore > rainScore && tokyoScore > terracottaScore) {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'tokyo_nocturne',
          telemetry: 'Semantic congruence matched Tokyo Nocturne (score $tokyoScore).',
        );
      }
      if (terracottaScore > rainScore && terracottaScore > tokyoScore) {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'raw_terracotta',
          telemetry: 'Semantic congruence matched Raw Terracotta (score $terracottaScore).',
        );
      }
      if (rainScore > 0) {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'rain_study',
          telemetry: 'Semantic congruence matched Rain & Study (score $rainScore).',
        );
      }
    }

    // 2. Dominant Hue Angle Cosine Congruence
    if (dominantHueDegrees != null) {
      double angleDistance(double h1, double h2) {
        final diff = (h1 - h2).abs() % 360.0;
        return diff > 180.0 ? 360.0 - diff : diff;
      }

      final dRain = angleDistance(dominantHueDegrees, rainStudyHue);
      final dTokyo = angleDistance(dominantHueDegrees, tokyoNocturneHue);
      final dTerracotta = angleDistance(dominantHueDegrees, rawTerracottaHue);

      final minDiff = math.min(dRain, math.min(dTokyo, dTerracotta));

      if (minDiff == dTokyo) {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'tokyo_nocturne',
          telemetry: 'Hue angle ${dominantHueDegrees.toStringAsFixed(1)}° matched Tokyo Nocturne.',
        );
      } else if (minDiff == dTerracotta) {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'raw_terracotta',
          telemetry: 'Hue angle ${dominantHueDegrees.toStringAsFixed(1)}° matched Raw Terracotta.',
        );
      } else {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'rain_study',
          telemetry: 'Hue angle ${dominantHueDegrees.toStringAsFixed(1)}° matched Rain & Study.',
        );
      }
    }

    return VerifierResult(
      status: VerifierStatus.repair,
      value: defaultFallback,
      telemetry: 'Indeterminate congruence: fallback to $defaultFallback.',
    );
  }
}
