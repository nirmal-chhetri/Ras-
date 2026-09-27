import 'dart:math' as math;

/// ============================================================================
/// FILE: lib/core/verifiers/deterministic_verifiers.dart
/// ARCHITECTURE LAYER: Deterministic Verifiers & Invariant Gates (Phase 2)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// Aether enforces rigorous mathematical and aesthetic invariant gates across
/// all catalog ingestion and rendering pipelines. These verifiers prevent layout
/// jumps, low-fidelity imagery, and aesthetic incongruity.
///
/// THREE DETERMINISTIC VERIFIER GATES:
///
/// 1. Verifier Gate 1: Visual Resolution (Fidelity Assertion)
///    - Formula: $\mathcal{V}_{res}(img) = \text{PASS}$ iff
///      $\min(width, height) \ge 600\text{px}$ AND $byteSize \le 12\text{MB}$.
///    - Prevents pixelated, blurry, or gigabyte-sized runaway images from
///      degrading the tactile editorial experience.
///
/// 2. Verifier Gate 2: Aspect Ratio Bounds (Masonry Integrity)
///    - Formula: $\mathcal{V}_{ar}(ratio) = \text{PASS}$ iff
///      $0.75 \le ratio \le 1.33$.
///    - If raw $ratio < 0.75$ (too tall/thin) or $ratio > 1.33$ (too wide/panoramic),
///      it returns [VerifierStatus.repair] and clamps the ratio to the boundary.
///    - Includes [AspectRatioVerifier.calculateCenterWeightedCrop] to compute
///      exact pixel-space crop boxes centered on the focal visual mass.
///
/// 3. Verifier Gate 3: Crossmodal Audio-Visual Congruence
///    - Matches specimen color palettes (dominant hue degrees $[0^\circ, 360^\circ)$)
///      and materiality keywords to one of the 3 atmospheric biomes:
///      - $210^\circ \pm 35^\circ$ / ['rain', 'slate', 'charcoal', 'paper', 'wood'] ➔ 'rain_study'
///      - $250^\circ \pm 35^\circ$ / ['tokyo', 'neon', 'obsidian', 'synth', 'metal'] ➔ 'tokyo_nocturne'
///      - $25^\circ \pm 35^\circ$ / ['terracotta', 'travertine', 'ceramic', 'warm'] ➔ 'raw_terracotta'
///
/// EXTENSION GUIDE FOR FUTURE DEVELOPERS:
/// - To add a 4th Verifier Gate (e.g. Accessibility Contrast Verifier):
///   Create a class following the [VerifierResult] pattern with deterministic
///   pass/repair/fail outcomes and telemetry logs.
/// ============================================================================

/// Outcome states for deterministic verifiers.
enum VerifierStatus {
  /// The input strictly met all invariant constraints without modification.
  pass,

  /// The input violated soft bounds but was deterministically repaired/clamped.
  repair,

  /// The input violated hard bounds and was rejected.
  fail,
}

/// Strongly typed result container emitted by verifier gates.
class VerifierResult<T> {
  /// The decision status (pass, repair, fail).
  final VerifierStatus status;

  /// The verified (or repaired) payload value.
  final T value;

  /// Human-readable telemetry log detailing the mathematical decision.
  final String telemetry;

  const VerifierResult({
    required this.status,
    required this.value,
    required this.telemetry,
  });

  /// True if the result passed cleanly.
  bool get isPass => status == VerifierStatus.pass;

  /// True if the result was clamped or adjusted into valid bounds.
  bool get isRepaired => status == VerifierStatus.repair;

  /// True if the input failed hard verification.
  bool get isFail => status == VerifierStatus.fail;
}

/// ============================================================================
/// VERIFIER GATE 1: Visual Resolution (Fidelity Assertion)
/// ============================================================================
/// Asserts that any visual asset meets minimum resolution and size standards.
class VisualResolutionVerifier {
  /// Minimum allowed dimension (width or height) in pixels.
  static const int minDimensionPixels = 600;

  /// Maximum allowed raw payload size in bytes (12 Megabytes).
  static const int maxByteSize = 12 * 1024 * 1024;

  /// Evaluates image fidelity invariants.
  ///
  /// Rejects images where $\min(width, height) < 600$ or $size > 12\text{MB}$.
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
        telemetry:
            'Resolution $width x $height fails min bound ($minDimensionPixels px).',
      );
    }

    if (byteSize != null && byteSize > maxByteSize) {
      return VerifierResult(
        status: VerifierStatus.fail,
        value: false,
        telemetry:
            'Asset size ${(byteSize / (1024 * 1024)).toStringAsFixed(1)}MB exceeds limit (12MB).',
      );
    }

    return VerifierResult(
      status: VerifierStatus.pass,
      value: true,
      telemetry:
          'Fidelity assertion verified: $width x $height (${byteSize ?? 0} bytes).',
    );
  }
}

/// ============================================================================
/// VERIFIER GATE 2: Aspect Ratio Bounds (Masonry Integrity)
/// ============================================================================
/// Asserts that specimen tiles fit inside the aesthetic interval [0.75, 1.33].
/// Clamps extreme vertical/horizontal ratios to maintain feed rhythm.
class AspectRatioVerifier {
  /// Minimum vertical aspect ratio (3:4 ratio = 0.75).
  static const double minBound = 0.75;

  /// Maximum horizontal aspect ratio (4:3 ratio = 1.33).
  static const double maxBound = 1.33;

  /// Verifies a raw aspect ratio against [0.75, 1.33] and clamps if needed.
  ///
  /// - If [rawRatio] is NaN, infinite, or negative, repairs to 1.0 (golden square).
  /// - If [rawRatio] < 0.75, repairs and clamps to 0.75.
  /// - If [rawRatio] > 1.33, repairs and clamps to 1.33.
  /// - Otherwise, passes unmodified.
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
      telemetry:
          'Aspect ratio $rawRatio within masonry bounds [$minBound, $maxBound].',
    );
  }

  /// Calculates a center-weighted crop rectangle within the original image dimensions.
  ///
  /// Crops excess height if the image is too tall, or excess width if too wide,
  /// preserving the visual center of mass.
  static math.Rectangle<double> calculateCenterWeightedCrop({
    required double originalWidth,
    required double originalHeight,
  }) {
    final rawRatio = originalWidth / originalHeight;

    double targetWidth = originalWidth;
    double targetHeight = originalHeight;

    if (rawRatio < minBound) {
      // Too tall: crop height to fit 0.75
      targetHeight = originalWidth / minBound;
    } else if (rawRatio > maxBound) {
      // Too wide: crop width to fit 1.33
      targetWidth = originalHeight * maxBound;
    }

    final offsetX = (originalWidth - targetWidth) / 2.0;
    final offsetY = (originalHeight - targetHeight) / 2.0;

    return math.Rectangle(offsetX, offsetY, targetWidth, targetHeight);
  }
}

/// ============================================================================
/// VERIFIER GATE 3: Crossmodal Audio-Visual Congruency
/// ============================================================================
/// Deterministically maps visual color palettes and material semantics
/// to the most fitting acoustic atmosphere.
class CrossmodalCongruenceVerifier {
  /// Hue angle benchmark for Slate Charcoal (rain/desk/slate).
  static const double rainStudyHue = 210.0;

  /// Hue angle benchmark for Obsidian Neon (tokyo/synth/nocturne).
  static const double tokyoNocturneHue = 250.0;

  /// Hue angle benchmark for Warm Travertine (clay/ceramic/terracotta).
  static const double rawTerracottaHue = 25.0;

  /// Matches semantic keywords or color hue to an atmosphere ID.
  ///
  /// Resolution order:
  /// 1. Keyword semantic scoring (lexical analysis on materials and title).
  /// 2. Hue angle angular distance calculation on a $360^\circ$ color wheel.
  /// 3. Fallback to [defaultFallback] if undetermined.
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

      for (final kw in [
        'rain',
        'slate',
        'charcoal',
        'paper',
        'wood',
        'cast iron',
        'lamp',
        'desk'
      ]) {
        if (text.contains(kw)) rainScore += 2;
      }
      for (final kw in [
        'tokyo',
        'neon',
        'obsidian',
        'dark',
        'oled',
        'synth',
        'metal',
        'keyboard',
        'headphone'
      ]) {
        if (text.contains(kw)) tokyoScore += 2;
      }
      for (final kw in [
        'terracotta',
        'travertine',
        'ceramic',
        'mug',
        'stone',
        'lounge',
        'warm',
        'clay',
        'beech'
      ]) {
        if (text.contains(kw)) terracottaScore += 2;
      }

      if (tokyoScore > rainScore && tokyoScore > terracottaScore) {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'tokyo_nocturne',
          telemetry:
              'Semantic congruence matched Tokyo Nocturne (score $tokyoScore).',
        );
      }
      if (terracottaScore > rainScore && terracottaScore > tokyoScore) {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'raw_terracotta',
          telemetry:
              'Semantic congruence matched Raw Terracotta (score $terracottaScore).',
        );
      }
      if (rainScore > 0) {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'rain_study',
          telemetry:
              'Semantic congruence matched Rain & Study (score $rainScore).',
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
          telemetry:
              'Hue angle ${dominantHueDegrees.toStringAsFixed(1)}° matched Tokyo Nocturne.',
        );
      } else if (minDiff == dTerracotta) {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'raw_terracotta',
          telemetry:
              'Hue angle ${dominantHueDegrees.toStringAsFixed(1)}° matched Raw Terracotta.',
        );
      } else {
        return VerifierResult(
          status: VerifierStatus.pass,
          value: 'rain_study',
          telemetry:
              'Hue angle ${dominantHueDegrees.toStringAsFixed(1)}° matched Rain & Study.',
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
