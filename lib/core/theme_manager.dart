import 'package:flutter/material.dart';
import 'theme.dart';

/// Phase 3: Dynamic ThemeManager
/// Coordinates dynamic theme morphing between Slate Charcoal, Obsidian Neon,
/// and Warm Travertine with configurable transition curves and persistence.
class ThemeManager extends ChangeNotifier {
  AetherTheme _currentTheme;
  Duration _animationDuration;
  Curve _animationCurve;

  ThemeManager({
    AetherTheme? initialTheme,
    Duration animationDuration = const Duration(milliseconds: 400),
    Curve animationCurve = Curves.easeInOutCubic,
  })  : _currentTheme = initialTheme ?? AetherTheme.slateCharcoal,
        _animationDuration = animationDuration,
        _animationCurve = animationCurve;

  AetherTheme get currentTheme => _currentTheme;
  String get activeAtmosphereId => _currentTheme.id;
  Duration get animationDuration => _animationDuration;
  Curve get animationCurve => _animationCurve;
  ThemeData get themeData => _currentTheme.toThemeData();

  void switchAtmosphere(String atmosphereId) {
    if (_currentTheme.id == atmosphereId) return;
    _currentTheme = AetherTheme.fromAtmosphereId(atmosphereId);
    notifyListeners();
  }

  void setTheme(AetherTheme newTheme) {
    if (_currentTheme.id == newTheme.id) return;
    _currentTheme = newTheme;
    notifyListeners();
  }

  void setTransitionConfig({Duration? duration, Curve? curve}) {
    if (duration != null) _animationDuration = duration;
    if (curve != null) _animationCurve = curve;
    notifyListeners();
  }
}
