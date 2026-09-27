import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// ============================================================================
/// FILE: lib/core/audio_controller.dart
/// ARCHITECTURE LAYER: Audio Subsystem & Sensory Telemetry Coordinator (Phase 4)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// [AudioEngineController] is the central presentation controller responsible for
/// driving the ambient acoustic soundscapes in Aether. It orchestrates:
///
/// 1. Seamless Seamless Audio Looping:
///    Uses [just_audio] with [LoopMode.one] to continuously stream atmospheric
///    background audio (rain, nocturnal synth drone, warm tape flutter).
///
/// 2. Browser Autoplay Handling & Graceful Recovery:
///    Modern web browsers strictly block automated sound playback prior to the
///    user's first physical gesture with a DOM `NotAllowedError`.
///    Rather than crashing or showing ugly error banners, [AudioEngineController]
///    catches this error, sets [needsUserGesture] to true, and signals the UI
///    capsule in [AudioDock] to display "CLICK TO TUNE IN". A single tap on the
///    dock clears the flag and immediately resumes playback.
///
/// 3. Stepped Volume Crossfading:
///    Directly switching digital audio tracks often produces noticeable
///    hardware pop/click artifacts. [_fadeVolume] implements a smooth 4-step
///    interpolation curve to power down volume before swapping asset sources
///    and ramping back up.
///
/// 4. Biological Waveform Visualizer Stream:
///    Provides a 60ms simulated acoustic breathing envelope via [amplitudeStream].
///    Uses harmonic sinusoidal equations ($0.42 + 0.32\sin(\theta) + 0.14\cos(2.3\theta)$)
///    to model natural, non-mechanical rhythmic pulses for the [AudioDock] painter.
///
/// 5. Volume Preset Cycling:
///    [cycleVolume] offers an intuitive one-tap toggle for fast mobile control:
///    `100% -> 70% -> 35% -> Muted -> 100%`.
///
/// EXTENSION GUIDE FOR FUTURE DEVELOPERS:
/// - To connect real FFT frequency hardware analysis:
///   Replace [_startVisualizerSimulator] with a hardware stream listener from
///   a native platform channel or web WebAudio `AnalyserNode`.
/// ============================================================================

/// Manages ambient background audio, volume crossfades, and visualizer telemetry.
class AudioEngineController extends ChangeNotifier {
  /// The underlying [just_audio] player instance.
  AudioPlayer? _player;

  /// The active asset track path currently loaded or playing.
  String? _currentTrack;

  /// True if audio is actively playing through the hardware output.
  bool _isPlaying = false;

  /// The target volume level bounded in range [0.0, 1.0]. Defaults to 0.8 (80%).
  double _volume = 0.8;

  /// Stored pre-attenuation volume level before acoustic ducking occurred.
  double _preDuckVolume = 0.8;

  /// Indicates whether audio is currently ducked during high-cognitive inspection tasks.
  bool _isDucked = false;

  /// Indicates whether audio output is temporarily muted.
  bool _isMuted = false;

  /// Set to true when a browser autoplay policy blocks unprompted playback.
  bool _needsUserGesture = false;

  /// Broadcast stream controller delivering live normalized amplitudes [0.0, 1.0]
  /// to visualizer widgets like [AudioDock].
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();

  /// Periodic timer driving the biological visualizer simulator.
  Timer? _visualizerTimer;

  /// Public broadcast stream of real-time acoustic amplitudes.
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  /// Whether the player is currently playing.
  bool get isPlaying => _isPlaying;

  /// Current master volume level [0.0, 1.0].
  double get volume => _volume;

  /// True if the engine is muted.
  bool get isMuted => _isMuted;

  /// True if audio is actively ducked to 20% for cognitive inspection.
  bool get isDucked => _isDucked;

  /// True if awaiting a physical user click to satisfy browser audio security policies.
  bool get needsUserGesture => _needsUserGesture;

  /// The asset path of the currently selected track.
  String? get currentTrack => _currentTrack;

  /// Initializes the audio player and starts the visualizer pulse timer.
  AudioEngineController() {
    _initPlayer();
    _startVisualizerSimulator();
  }

  /// Internal asynchronous initializer setting up loop mode and initial volume.
  Future<void> _initPlayer() async {
    try {
      _player = AudioPlayer();
      await _player?.setLoopMode(LoopMode.one);
      await _player?.setVolume(_volume);
    } catch (e) {
      debugPrint('Audio initialization note (expected in headless tests): $e');
    }
  }

  /// Generates a natural biological breathing waveform stream for the visualizer.
  ///
  /// When audio is paused or muted, emits a flat baseline (0.04).
  /// When playing, combines fundamental and harmonic sinusoidal phases with
  /// subtle stochastic jitter to create an organic, living pulse.
  void _startVisualizerSimulator() {
    double phase = 0.0;
    _visualizerTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (!_isPlaying || _isMuted) {
        _amplitudeController.add(0.04);
        return;
      }
      phase += 0.15;
      final raw = 0.42 +
          0.32 * sin(phase) +
          0.14 * cos(phase * 2.3) +
          (Random().nextDouble() * 0.08);
      final normalized = raw.clamp(0.08, 0.95);
      _amplitudeController.add(normalized);
    });
  }

  /// Smooth volume fader that interpolates volume across [durationMs] in discrete steps.
  /// Prevents audio pops, clipping, or harsh digital cuts during atmosphere switches and ducking.
  Future<void> _fadeVolume({
    required double from,
    required double to,
    int durationMs = 150,
  }) async {
    if (_player == null) return;
    final steps = max(4, (durationMs / 35).round());
    final stepDuration = Duration(milliseconds: max(10, (durationMs / steps).round()));
    final delta = (to - from) / steps;

    for (int i = 1; i <= steps; i++) {
      final current = (from + delta * i).clamp(0.0, 1.0);
      try {
        await _player?.setVolume(current);
      } catch (_) {}
      await Future.delayed(stepDuration);
    }
  }

  /// Transitions the background audio loop to a new atmosphere's asset path.
  ///
  /// Steps:
  /// 1. Smoothly fades existing audio down to silence (120ms).
  /// 2. Loads the new asset bundle path.
  /// 3. Attempts autoplay with web browser policy error interception.
  /// 4. Smoothly fades back up to the target volume level (160ms).
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
          await _fadeVolume(
            from: 0.0,
            to: _isMuted ? 0.0 : _volume,
            durationMs: 160,
          );
        } catch (e) {
          // If browser blocked autoplay before first physical gesture
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

  /// Toggles between playback and pause states with crossfade cushioning.
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
        await _fadeVolume(
          from: 0.0,
          to: _isMuted ? 0.0 : _volume,
          durationMs: 150,
        );
      }
    } catch (e) {
      debugPrint('Toggle playback error handled: $e');
    }
    notifyListeners();
  }

  /// Sets master volume to an exact value in range [0.0, 1.0].
  /// If set to 0.0, marks [_isMuted] as true automatically.
  Future<void> setVolume(double val) async {
    _volume = val.clamp(0.0, 1.0);
    _isMuted = _volume == 0.0;
    notifyListeners();
    try {
      await _player?.setVolume(_isMuted ? 0.0 : _volume);
    } catch (e) {
      debugPrint('Volume adjustment error: $e');
    }
  }

  /// Toggles mute state without discarding the configured volume level.
  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
    _player?.setVolume(_isMuted ? 0.0 : _volume);
  }

  /// Cycles volume through four intuitive steps:
  /// `100% -> 70% -> 35% -> Muted -> 100%`.
  /// Designed for seamless one-touch adjustments on the [AudioDock].
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

  /// PSYCHOACOUSTIC ATTENUATION & DUCKING (Phase 4)
  /// SCIENTIFIC PRINCIPLE: Crossmodal Attention & Cognitive Load (Spence, 2011; Sweller, 2011)
  ///
  /// Abrupt acoustic cutoffs trigger the acoustic startle reflex (Davis, 1984),
  /// while loud background soundscapes compete with verbal working memory during
  /// focused monograph inspection or decision-making (Split-Attention Effect).
  ///
  /// This method smoothly ducks ambient sound down to [duckRatio] (default 20% / 0.20)
  /// over [durationMs] (default 400ms), maintaining environmental immersion without
  /// inducing startle or monopolizing cognitive bandwidth.
  Future<void> duckAudio({double duckRatio = 0.20, int durationMs = 400}) async {
    if (_isDucked || _isMuted) return;
    _isDucked = true;
    _preDuckVolume = _volume;
    final targetDuckedVolume = (_volume * duckRatio).clamp(0.0, 1.0);
    notifyListeners();

    try {
      if (_player != null && _isPlaying) {
        await _fadeVolume(
          from: _volume,
          to: targetDuckedVolume,
          durationMs: durationMs,
        );
      }
    } catch (e) {
      debugPrint('Acoustic ducking error: $e');
    }
  }

  /// Restores ducked audio to its pre-attenuation level over [durationMs] (default 800ms).
  ///
  /// A slower ramp-up (800ms) prevents auditory intrusion when exiting focus tasks,
  /// creating a gentle acoustic re-entry into the ambient sanctuary.
  Future<void> restoreAudio({int durationMs = 800}) async {
    if (!_isDucked) return;
    _isDucked = false;
    notifyListeners();

    try {
      if (_player != null && _isPlaying && !_isMuted) {
        final current = _player?.volume ?? (_volume * 0.20);
        await _fadeVolume(
          from: current,
          to: _preDuckVolume,
          durationMs: durationMs,
        );
      }
    } catch (e) {
      debugPrint('Acoustic restore error: $e');
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
