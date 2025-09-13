import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WaveformWidget extends StatelessWidget {
  final double amplitude;
  final bool isRecording;
  final Color waveColor;
  final double height;

  const WaveformWidget({
    super.key,
    required this.amplitude,
    required this.isRecording,
    this.waveColor = Colors.blue,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomPaint(
        painter: WaveformPainter(
          amplitude: amplitude,
          isRecording: isRecording,
          waveColor: waveColor,
        ),
        child: Container(),
      ),
    ).animate(
      onComplete: (controller) {
        if (isRecording) {
          controller.repeat();
        }
      },
    ).shimmer(
      duration: const Duration(seconds: 2),
      color: waveColor.withValues(alpha: 0.3),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double amplitude;
  final bool isRecording;
  final Color waveColor;

  WaveformPainter({
    required this.amplitude,
    required this.isRecording,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;
    final waveHeight = size.height * 0.3 * (amplitude.clamp(0.0, 1.0));

    path.moveTo(0, centerY);

    for (double x = 0; x <= size.width; x += 2) {
      final progress = x / size.width;
      final y = centerY +
          sin(progress * 4 * pi) * waveHeight * (isRecording ? 1.0 : 0.3);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw center line
    final centerLinePaint = Paint()
      ..color = waveColor.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerLinePaint,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return amplitude != oldDelegate.amplitude ||
        isRecording != oldDelegate.isRecording;
  }
}