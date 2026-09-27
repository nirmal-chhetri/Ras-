import 'package:flutter/material.dart';
import 'theme.dart';

/// ============================================================================
/// FILE: lib/core/theme_manager.dart
/// ARCHITECTURE LAYER: Presentation State Coordinator (Phase 3)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// [ThemeManager] is a [ChangeNotifier] that orchestrates dynamic, silky-smooth
/// visual skin morphing across the application. When a user or automated circadian
/// trigger selects an atmosphere (e.g. switching from 'rain_study' to 'raw_terracotta'),
/// [ThemeManager] updates its active [AetherTheme] and alerts all subscribed
/// widgets via [notifyListeners].
///
/// KEY FEATURES:
/// 1. Zero-Jank Interpolation:
///    Designed to pair seamlessly with Flutter's [AnimatedTheme] widget, using
///    a default 400ms duration and [Curves.easeInOutCubic] curve so background
///    colors, card surfaces, and border hairpins morph organically.
///
/// 2. Idempotent State Changes:
///    Guards against redundant re-render cascades if the newly selected
///    atmosphere is already the active one.
///
/// 3. Pluggable Animation Tuning:
///    Allows runtime adjustment of animation curves and durations via
///    [setTransitionConfig] for accessibility or preference customizations.
///
/// EXTENSION GUIDE FOR FUTURE DEVELOPERS:
/// - To add persistent theme memory across app restarts:
///   Inject [IStorageGateway] into [ThemeManager] and read/write the active
///   atmosphere ID via [IStorageGateway.persistPreference].
/// ============================================================================

/// Coordinates dynamic visual theme transitions across atmospheric biomes.
class ThemeManager extends ChangeNotifier {
  /// The active theme token configuration.
  AetherTheme _currentTheme;

  /// The duration applied to [AnimatedTheme] color interpolation.
  Duration _animationDuration;

  /// The mathematical easing curve applied to visual transitions.
  Curve _animationCurve;

  /// Creates a [ThemeManager] with an optional starting theme and transition parameters.
  /// Defaults to [AetherTheme.slateCharcoal] with a 400ms cubic ease.
  ThemeManager({
    AetherTheme? initialTheme,
    Duration animationDuration = const Duration(milliseconds: 400),
    Curve animationCurve = Curves.easeInOutCubic,
  })  : _currentTheme = initialTheme ?? AetherTheme.slateCharcoal,
        _animationDuration = animationDuration,
        _animationCurve = animationCurve;

  /// Exposes the current active [AetherTheme] tokens (colors, borders, glows).
  AetherTheme get currentTheme => _currentTheme;

  /// Returns the string identifier of the current atmosphere (e.g. 'rain_study').
  String get activeAtmosphereId => _currentTheme.id;

  /// The active animation duration for theme transitions.
  Duration get animationDuration => _animationDuration;

  /// The active animation curve for theme transitions.
  Curve get animationCurve => _animationCurve;

  /// Helper returning the full Flutter [ThemeData] representation of [_currentTheme].
  ThemeData get themeData => _currentTheme.toThemeData();

  /// Transitions the theme to match the provided [atmosphereId].
  ///
  /// If the ID matches the current active atmosphere, the call is a no-op,
  /// preventing wasteful UI re-layouts.
  void switchAtmosphere(String atmosphereId) {
    if (_currentTheme.id == atmosphereId) return;
    _currentTheme = AetherTheme.fromAtmosphereId(atmosphereId);
    notifyListeners();
  }

  /// Directly assigns a specific [AetherTheme] instance.
  ///
  /// Useful in testing, theme preview galleries, or custom user palette editors.
  void setTheme(AetherTheme newTheme) {
    if (_currentTheme.id == newTheme.id) return;
    _currentTheme = newTheme;
    notifyListeners();
  }

  /// Dynamically updates the transition timing parameters.
  ///
  /// Useful for users requesting reduced motion (can be set to [Duration.zero]).
  void setTransitionConfig({Duration? duration, Curve? curve}) {
    if (duration != null) _animationDuration = duration;
    if (curve != null) _animationCurve = curve;
    notifyListeners();
  }
}
