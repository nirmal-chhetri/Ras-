import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/audio_controller.dart';

class AudioDock extends StatefulWidget {
  final AudioEngineController audioController;
  final AetherTheme theme;
  final String activeAtmosphereName;
  final String telemetryFrequency;

  const AudioDock({
    super.key,
    required this.audioController,
    required this.theme,
    required this.activeAtmosphereName,
    required this.telemetryFrequency,
  });

  @override
  State<AudioDock> createState() => _AudioDockState();
}

class _AudioDockState extends State<AudioDock> {
  @override
  void initState() {
    super.initState();
    widget.audioController.addListener(_onAudioStateChanged);
  }

  @override
  void didUpdateWidget(AudioDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioController != widget.audioController) {
      oldWidget.audioController.removeListener(_onAudioStateChanged);
      widget.audioController.addListener(_onAudioStateChanged);
    }
  }

  @override
  void dispose() {
    widget.audioController.removeListener(_onAudioStateChanged);
    super.dispose();
  }

  void _onAudioStateChanged() {
    setState(() {});
  }

  IconData _getVolumeIcon() {
    final controller = widget.audioController;
    if (controller.isMuted || controller.volume == 0.0) {
      return Icons.volume_off_rounded;
    } else if (controller.volume < 0.4) {
      return Icons.volume_mute_rounded;
    } else if (controller.volume < 0.75) {
      return Icons.volume_down_rounded;
    }
    return Icons.volume_up_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.audioController;
    final theme = widget.theme;
    final isPlaying = controller.isPlaying;
    final needsGesture = controller.needsUserGesture;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        height: 54,
        decoration: BoxDecoration(
          color: theme.bgSurface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: needsGesture
                ? theme.accentGlow.withValues(alpha: 0.8)
                : theme.borderHairline.withValues(alpha: 0.75),
            width: needsGesture ? 1.4 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // 1. Play / Pause / Tune-in Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.togglePlayPause();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: needsGesture || isPlaying
                            ? theme.accentGlow
                            : theme.textPrimary.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 20,
                        color: needsGesture || isPlaying
                            ? Colors.white
                            : theme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 2. Live Sound Waveform Visualizer
                Expanded(
                  child: StreamBuilder<double>(
                    stream: controller.amplitudeStream,
                    initialData: 0.25,
                    builder: (context, snapshot) {
                      final amp = snapshot.data ?? 0.25;
                      return CustomPaint(
                        size: const Size(double.infinity, 26),
                        painter: _WaveformPainter(
                          amplitude: amp,
                          isPlaying: isPlaying,
                          primaryColor: theme.textPrimary,
                          accentColor: theme.accentGlow,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // 3. Volume Preset Cycle Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.cycleVolume();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.textPrimary.withValues(alpha: 0.06),
                      ),
                      child: Icon(
                        _getVolumeIcon(),
                        size: 16,
                        color: controller.isMuted
                            ? theme.textSecondary.withValues(alpha: 0.5)
                            : theme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 4. Acoustic Telemetry & Frequency Display
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      needsGesture
                          ? 'CLICK TO TUNE IN'
                          : widget.activeAtmosphereName.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: needsGesture ? theme.accentGlow : theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.telemetryFrequency,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8.0,
                        fontWeight: FontWeight.w500,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double amplitude;
  final bool isPlaying;
  final Color primaryColor;
  final Color accentColor;

  _WaveformPainter({
    required this.amplitude,
    required this.isPlaying,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = (size.width / 5.5).floor().clamp(10, 36);
    final spacing = size.width / barCount;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = (i * spacing) + 2.5;
      final factor = (i - barCount / 2).abs() / (barCount / 2);
      final heightMultiplier = (1.0 - factor * 0.42);

      final barHeight = isPlaying
          ? (size.height * 0.82 * amplitude * heightMultiplier).clamp(2.5, size.height - 2)
          : 2.5;

      final isCenter = (i >= barCount / 3) && (i <= 2 * barCount / 3);
      final paint = Paint()
        ..color = (isCenter && isPlaying ? accentColor : primaryColor).withValues(alpha: 0.75)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}
