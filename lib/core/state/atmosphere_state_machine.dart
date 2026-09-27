import 'package:flutter/material.dart';
import '../gateways/audio_gateway.dart';
import '../theme.dart';

/// ============================================================================
/// FILE: lib/core/state/atmosphere_state_machine.dart
/// ARCHITECTURE LAYER: Graph 1 — Circadian Atmosphere StateGraph (Phase 2)
/// PROJECT: Aether • Ākāśa (आकाश) — Ambient Slow-Commerce & Sensory Sanctuary
/// ============================================================================
///
/// OVERVIEW:
/// [AtmosphereStateMachine] implements the Circadian Atmospheric State Machine
/// specified in GRAPH_WORKFLOWS.md. It models the system as a formal state graph
/// where sensory transitions between biomes undergo deterministic precondition
/// checks, audio crossfading, and visual token shifts.
///
/// STATE GRAPH ARCHITECTURE:
/// - States:
///   - 'rain_study' (Slate Charcoal, rain acoustic loop, 800Hz–4kHz)
///   - 'tokyo_nocturne' (Obsidian Neon, nocturnal drone, 60Hz sub-drone)
///   - 'raw_terracotta' (Warm Travertine, tape flutter, 432Hz lo-fi)
///
/// - Transition Nodes:
///   1. Check Audio Conflict: Queries [IAudioGateway.checkExternalAudioActive].
///      If the user is already listening to external audio (e.g. Spotify),
///      mutes ambient sound and triggers silent theme morphing.
///   2. Audio Engine Action: Triggers smooth crossfading via [IAudioGateway.crossfadeTo].
///   3. Visual Skin Morph: Updates state with corresponding [AetherTheme] tokens
///      and alerts listening widgets.
///
/// EXTENSION GUIDE FOR FUTURE DEVELOPERS:
/// - To add automated circadian time triggers:
///   Add a periodic timer that checks `DateTime.now().hour` and automatically
///   transitions between daylight ('raw_terracotta'), afternoon ('rain_study'),
///   and night ('tokyo_nocturne').
/// ============================================================================

/// Immutable State Schema for Graph 1 (Atmospheric State Machine).
@immutable
class AtmosphereState {
  /// Unique identifier of the current active atmosphere.
  final String activeId;

  /// Human-readable title of the active atmosphere.
  final String displayName;

  /// Background primary color for canvas scaffolds.
  final Color backgroundColor;

  /// Elevated surface color for cards, bottom sheets, and dialogs.
  final Color surfaceColor;

  /// High-contrast text color.
  final Color primaryTextColor;

  /// Atmospheric accent glow color for active indicators and waveforms.
  final Color accentGlow;

  /// Bundled asset path to the active atmospheric audio track.
  final String audioAssetPath;

  /// Tabular frequency badge string for live telemetry.
  final String telemetryFrequency;

  /// Target volume level in range [0.0, 1.0].
  final double targetVolume;

  /// True if audio output is muted.
  final bool isAudioMuted;

  /// True if external hardware audio playback was detected.
  final bool isExternalAudioDetected;

  const AtmosphereState({
    required this.activeId,
    required this.displayName,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.primaryTextColor,
    required this.accentGlow,
    required this.audioAssetPath,
    required this.telemetryFrequency,
    this.targetVolume = 0.8,
    this.isAudioMuted = false,
    this.isExternalAudioDetected = false,
  });

  /// Factory providing the initial baseline state ('rain_study' / Slate Charcoal).
  factory AtmosphereState.initial() {
    return const AtmosphereState(
      activeId: 'rain_study',
      displayName: 'Rain & Study',
      backgroundColor: Color(0xFF16181D),
      surfaceColor: Color(0xFF1E2128),
      primaryTextColor: Color(0xFFF0F2F5),
      accentGlow: Color(0xFF5E81AC),
      audioAssetPath: 'assets/audio/rain_study.ogg',
      telemetryFrequency: '800Hz–4kHz Rain Resonance',
      targetVolume: 0.8,
      isAudioMuted: false,
      isExternalAudioDetected: false,
    );
  }

  /// Creates a copy of the state with selected fields replaced.
  AtmosphereState copyWith({
    String? activeId,
    String? displayName,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? primaryTextColor,
    Color? accentGlow,
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
      accentGlow: accentGlow ?? this.accentGlow,
      audioAssetPath: audioAssetPath ?? this.audioAssetPath,
      telemetryFrequency: telemetryFrequency ?? this.telemetryFrequency,
      targetVolume: targetVolume ?? this.targetVolume,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isExternalAudioDetected:
          isExternalAudioDetected ?? this.isExternalAudioDetected,
    );
  }
}

/// Atmospheric State Machine (Circadian Graph Coordinator).
class AtmosphereStateMachine extends ChangeNotifier {
  final IAudioGateway _audioGateway;
  AtmosphereState _state = AtmosphereState.initial();

  /// The current immutable atmospheric state.
  AtmosphereState get state => _state;

  /// Live visualizer amplitude stream forwarded directly from the gateway.
  Stream<double> get amplitudeStream => _audioGateway.amplitudeStream;

  AtmosphereStateMachine({required IAudioGateway audioGateway})
      : _audioGateway = audioGateway {
    init();
  }

  /// Primes the audio gateway and detects initial audio conflicts.
  Future<void> init() async {
    final hasConflict = await _audioGateway.checkExternalAudioActive();
    if (hasConflict) {
      _state = _state.copyWith(
        isExternalAudioDetected: true,
        isAudioMuted: true,
      );
      notifyListeners();
    } else {
      await _audioGateway.crossfadeTo(_state.audioAssetPath);
    }
  }

  /// Transition Gate: Evaluates audio conflict, triggers crossfade, and morphs theme.
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

    // Node 1: Check audio conflict with external music players
    final conflict = await _audioGateway.checkExternalAudioActive();

    // Node 2: Audio Engine action (crossfade if unmuted and no conflict)
    if (!conflict && !_state.isAudioMuted) {
      await _audioGateway.crossfadeTo(audioPath);
    }

    // Node 3: Update state with theme tokens and telemetry
    _state = _state.copyWith(
      activeId: targetAtmosphereId,
      displayName: theme.name,
      backgroundColor: theme.bgPrimary,
      surfaceColor: theme.bgSurface,
      primaryTextColor: theme.textPrimary,
      accentGlow: theme.accentGlow,
      audioAssetPath: audioPath,
      telemetryFrequency: freq,
      isExternalAudioDetected: conflict,
    );

    notifyListeners();
  }

  /// Toggles mute state on the gateway and state.
  Future<void> toggleMute() async {
    final nextMuted = !_state.isAudioMuted;
    _state = _state.copyWith(isAudioMuted: nextMuted);
    await _audioGateway.setMuted(nextMuted);
    notifyListeners();
  }

  /// Adjusts master volume level in range [0.0, 1.0].
  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    _state = _state.copyWith(targetVolume: clamped);
    await _audioGateway.setVolume(clamped);
    notifyListeners();
  }
}
