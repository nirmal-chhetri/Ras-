import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioEngineController extends ChangeNotifier {
  AudioPlayer? _player;
  String? _currentTrack;
  bool _isPlaying = true;
  double _volume = 0.8;
  bool _isMuted = false;
  
  // Stream for the live audio visualizer
  final StreamController<double> _amplitudeController = StreamController<double>.broadcast();
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  Timer? _visualizerTimer;

  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  bool get isMuted => _isMuted;
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
    _visualizerTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!_isPlaying || _isMuted) {
        _amplitudeController.add(0.05);
        return;
      }
      phase += 0.15;
      final raw = 0.4 + 0.35 * sin(phase) + 0.15 * cos(phase * 2.3) + (Random().nextDouble() * 0.1);
      final normalized = raw.clamp(0.08, 0.95);
      _amplitudeController.add(normalized);
    });
  }

  Future<void> switchAtmosphereAudio(String assetPath) async {
    if (_currentTrack == assetPath) return;
    _currentTrack = assetPath;
    notifyListeners();

    try {
      if (_player != null) {
        // Crossfade: Linear power down
        await _player?.setVolume(0.0);
        await _player?.setAsset(assetPath);
        if (_isPlaying && !_isMuted) {
          await _player?.play();
          // Fade back up smoothly
          await _player?.setVolume(_volume);
        }
      }
    } catch (e) {
      debugPrint('Audio playback graceful fallback: $e');
    }
  }

  Future<void> togglePlayPause() async {
    _isPlaying = !_isPlaying;
    notifyListeners();
    try {
      if (_isPlaying) {
        await _player?.play();
      } else {
        await _player?.pause();
      }
    } catch (e) {
      debugPrint('Toggle error: $e');
    }
  }

  Future<void> setVolume(double val) async {
    _volume = val.clamp(0.0, 1.0);
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

  @override
  void dispose() {
    _visualizerTimer?.cancel();
    _amplitudeController.close();
    _player?.dispose();
    super.dispose();
  }
}
