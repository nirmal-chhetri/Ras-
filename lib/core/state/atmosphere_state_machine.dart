import 'package:flutter/material.dart';
import '../gateways/audio_gateway.dart';
import '../theme.dart';

/// Immutable State Schema for Graph 1 (Atmospheric State Machine)
class AtmosphereState {
  final String activeId; // 'rain_study' | 'tokyo_nocturne' | 'raw_terracotta'
  final String displayName;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color primaryTextColor;
  final Color accentColor;
  final String audioAssetPath;
  final String telemetryFrequency;
  final double targetVolume;
  final bool isAudioMuted;
  final bool isExternalAudioDetected;

  const AtmosphereState({
    required this.activeId,
    required this.displayName,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.primaryTextColor,
    required this.accentColor,
    required this.audioAssetPath,
    required this.telemetryFrequency,
    this.targetVolume = 0.8,
    this.isAudioMuted = false,
    this.isExternalAudioDetected = false,
  });

  factory AtmosphereState.initial() {
    return const AtmosphereState(
      activeId: 'rain_study',
      displayName: 'Rain & Study',
      backgroundColor: Color(0xFF16181D),
      surfaceColor: Color(0xFF1E2128),
      primaryTextColor: Color(0xFFF0F2F5),
      accentColor: Color(0xFF5E81AC),
      audioAssetPath: 'assets/audio/rain_study.ogg',
      telemetryFrequency: '800Hz–4kHz Rain Resonance',
      targetVolume: 0.8,
      isAudioMuted: false,
      isExternalAudioDetected: false,
    );
  }

  AtmosphereState copyWith({
    String? activeId,
    String? displayName,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? primaryTextColor,
    Color? accentColor,
    String? audioAssetPath,
    String? telemetryFrequency,
    double? targetVolume,
    bool? isAudioMuted,
    bool? isExternalAudioDetected,
  }) {
    return AtmosphereState(
      activeId: activeId ?? this.activeId,
      displayName: displayName ?? this.displayName,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      accentColor: accentColor ?? this.accentColor,
      audioAssetPath: audioAssetPath ?? this.audioAssetPath,
      telemetryFrequency: telemetryFrequency ?? this.telemetryFrequency,
      targetVolume: targetVolume ?? this.targetVolume,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isExternalAudioDetected: isExternalAudioDetected ?? this.isExternalAudioDetected,
    );
  }
}

/// Atmospheric State Machine (Circadian Graph Coordinator)
class AtmosphereStateMachine extends ChangeNotifier {
  final IAudioGateway _audioGateway;
  AtmosphereState _state = AtmosphereState.initial();

  AtmosphereState get state => _state;
  Stream<double> get amplitudeStream => _audioGateway.amplitudeStream;

  AtmosphereStateMachine({required IAudioGateway audioGateway})
      : _audioGateway = audioGateway {
    init();
  }

  Future<void> init() async {
    // Check initial audio conflicts and prime the engine
    final hasConflict = await _audioGateway.checkExternalAudioActive();
    if (hasConflict) {
      _state = _state.copyWith(isExternalAudioDetected: true, isAudioMuted: true);
      notifyListeners();
    } else {
      await _audioGateway.crossfadeTo(_state.audioAssetPath);
    }
  }

  /// Transition Gate: Evaluates audio conflict, triggers crossfade and morphs theme
  Future<void> transitionTo(String targetAtmosphereId) async {
    if (_state.activeId == targetAtmosphereId) return;

    final theme = AetherTheme.fromAtmosphereId(targetAtmosphereId);
    String audioPath = 'assets/audio/rain_study.ogg';
    String freq = '800Hz–4kHz Rain Resonance';

    if (targetAtmosphereId == 'tokyo_nocturne') {
      audioPath = 'assets/audio/tokyo_nocturne.wav';
      freq = '60Hz Sub-Drone & Neon Pulse';
    } else if (targetAtmosphereId == 'raw_terracotta') {
      audioPath = 'assets/audio/raw_terracotta.wav';
      freq = '432Hz Warm Lo-Fi Tape Flutter';
    }

    // Node 1: Check audio conflict
    final conflict = await _audioGateway.checkExternalAudioActive();

    // Node 2: Audio Engine action
    if (!conflict && !_state.isAudioMuted) {
      await _audioGateway.crossfadeTo(audioPath);
    }

    // Node 3: Update and morph state
    _state = _state.copyWith(
      activeId: targetAtmosphereId,
      displayName: theme.name,
      backgroundColor: theme.bgPrimary,
      surfaceColor: theme.bgSurface,
      primaryTextColor: theme.textPrimary,
      accentColor: theme.accentGlow,
      audioAssetPath: audioPath,
      telemetryFrequency: freq,
      isExternalAudioDetected: conflict,
    );

    notifyListeners();
  }

  Future<void> toggleMute() async {
    final nextMuted = !_state.isAudioMuted;
    _state = _state.copyWith(isAudioMuted: nextMuted);
    await _audioGateway.setMuted(nextMuted);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    _state = _state.copyWith(targetVolume: clamped);
    await _audioGateway.setVolume(clamped);
    notifyListeners();
  }
}
