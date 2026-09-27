import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Phase 4: Sensory Audio Engine Controller
/// Coordinates continuous looping audio, browser autoplay policy handling,
/// stepped volume crossfades, and biological waveform telemetry.
class AudioEngineController extends ChangeNotifier {
  AudioPlayer? _player;
  String? _currentTrack;
  bool _isPlaying = false;
  double _volume = 0.8;
  bool _isMuted = false;
  bool _needsUserGesture = false;
  
  // Stream for the live audio visualizer
  final StreamController<double> _amplitudeController = StreamController<double>.broadcast();
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  Timer? _visualizerTimer;

  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  bool get isMuted => _isMuted;
  bool get needsUserGesture => _needsUserGesture;
  String? get currentTrack => _currentTrack;

  AudioEngineController() {
    _initPlayer();
    _startVisualizerSimulator();
  }

  Future<void> _initPlayer() async {
    try {
      _player = AudioPlayer();
      await _player?.setLoopMode(LoopMode.one);
      await _player?.setVolume(_volume);
    } catch (e) {
      debugPrint('Audio initialization note: $e');
    }
  }

  void _startVisualizerSimulator() {
    // Generates a biological, natural breathing waveform stream for the visualizer
    double phase = 0.0;
    _visualizerTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (!_isPlaying || _isMuted) {
        _amplitudeController.add(0.04);
        return;
      }
      phase += 0.15;
      final raw = 0.42 + 0.32 * sin(phase) + 0.14 * cos(phase * 2.3) + (Random().nextDouble() * 0.08);
      final normalized = raw.clamp(0.08, 0.95);
      _amplitudeController.add(normalized);
    });
  }

  /// Smooth volume fader avoiding hardware click/pop glitches
  Future<void> _fadeVolume({
    required double from,
    required double to,
    int durationMs = 150,
  }) async {
    if (_player == null) return;
    const steps = 4;
    final stepDuration = Duration(milliseconds: (durationMs / steps).round());
    final delta = (to - from) / steps;

    for (int i = 1; i <= steps; i++) {
      final current = (from + delta * i).clamp(0.0, 1.0);
      try {
        await _player?.setVolume(current);
      } catch (_) {}
      await Future.delayed(stepDuration);
    }
  }

  Future<void> switchAtmosphereAudio(String assetPath) async {
    if (_currentTrack == assetPath) return;
    _currentTrack = assetPath;
    notifyListeners();

    try {
      if (_player != null) {
        // Step 1: Smooth power-down fade
        if (_isPlaying && !_isMuted) {
          await _fadeVolume(from: _volume, to: 0.0, durationMs: 120);
        } else {
          await _player?.setVolume(0.0);
        }

        // Step 2: Load new asset loop
        await _player?.setAsset(assetPath);

        // Step 3: Autoplay attempt (gracefully handles web autoplay policies)
        try {
          await _player?.play();
          _isPlaying = true;
          _needsUserGesture = false;
          await _fadeVolume(from: 0.0, to: _isMuted ? 0.0 : _volume, durationMs: 160);
        } catch (e) {
          // If browser blocked autoplay before first gesture
          _isPlaying = false;
          _needsUserGesture = true;
          await _player?.setVolume(_volume);
        }
      }
    } catch (e) {
      debugPrint('Audio playback graceful fallback: $e');
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _fadeVolume(from: _volume, to: 0.0, durationMs: 100);
        await _player?.pause();
        _isPlaying = false;
      } else {
        _needsUserGesture = false;
        await _player?.play();
        _isPlaying = true;
        await _fadeVolume(from: 0.0, to: _isMuted ? 0.0 : _volume, durationMs: 150);
      }
    } catch (e) {
      debugPrint('Toggle error: $e');
    }
    notifyListeners();
  }

  Future<void> setVolume(double val) async {
    _volume = val.clamp(0.0, 1.0);
    _isMuted = _volume == 0.0;
    notifyListeners();
    try {
      await _player?.setVolume(_isMuted ? 0.0 : _volume);
    } catch (e) {
      debugPrint('Volume error: $e');
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
    _player?.setVolume(_isMuted ? 0.0 : _volume);
  }

  /// Cycles volume presets: 100% -> 70% -> 35% -> Muted -> 100%
  void cycleVolume() {
    if (_isMuted || _volume == 0.0) {
      _isMuted = false;
      setVolume(1.0);
    } else if (_volume > 0.75) {
      setVolume(0.70);
    } else if (_volume > 0.40) {
      setVolume(0.35);
    } else {
      toggleMute();
    }
  }

  @override
  void dispose() {
    _visualizerTimer?.cancel();
    _amplitudeController.close();
    _player?.dispose();
    super.dispose();
  }
}
