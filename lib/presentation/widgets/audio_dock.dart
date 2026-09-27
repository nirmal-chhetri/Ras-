import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/audio_controller.dart';

class AudioDock extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        height: 52,
        decoration: BoxDecoration(
          color: theme.bgSurface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: theme.borderHairline.withValues(alpha: 0.8),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Play / Pause Icon Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    audioController.togglePlayPause();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.textPrimary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      audioController.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 18,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Animated Sound Wave Visualizer
                Expanded(
                  child: StreamBuilder<double>(
                    stream: audioController.amplitudeStream,
                    initialData: 0.3,
                    builder: (context, snapshot) {
                      final amp = snapshot.data ?? 0.3;
                      return CustomPaint(
                        size: const Size(double.infinity, 24),
                        painter: _WaveformPainter(
                          amplitude: amp,
                          isPlaying: audioController.isPlaying,
                          color: theme.textPrimary.withValues(alpha: 0.75),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Telemetry & Track Title
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      activeAtmosphereName.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      telemetryFrequency,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8.5,
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
  final Color color;

  _WaveformPainter({
    required this.amplitude,
    required this.isPlaying,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final barCount = (size.width / 6).floor().clamp(10, 36);
    final spacing = size.width / barCount;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = (i * spacing) + 3;
      // Simulated frequency wave distribution
      final factor = (i - barCount / 2).abs() / (barCount / 2);
      final heightMultiplier = (1.0 - factor * 0.45);
      
      final barHeight = isPlaying
          ? (size.height * 0.85 * amplitude * heightMultiplier).clamp(3.0, size.height - 2)
          : 3.0;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude || oldDelegate.isPlaying != isPlaying;
  }
}
