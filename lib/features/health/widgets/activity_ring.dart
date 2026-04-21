import 'dart:math';
import 'package:flutter/cupertino.dart';

class ActivityRing extends StatelessWidget {
  const ActivityRing({
    super.key,
    required this.progress,
    required this.color,
    this.gradient,
    this.strokeWidth = 10,
    this.size = 72,
  });

  final double progress;
  final Color color;
  final List<Color>? gradient;
  final double strokeWidth;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          color: color,
          gradient: gradient,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.gradient,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final List<Color>? gradient;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bg = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);

    if (progress <= 0) return;

    final g = gradient;
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    if (g != null && g.length >= 2) {
      fg.shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [...g, g.first],
        stops: [
          for (int i = 0; i < g.length; i++) i / g.length,
          1.0,
        ],
        transform: const GradientRotation(-pi / 2),
      ).createShader(rect);
    } else {
      fg.color = color;
    }

    const startAngle = -pi / 2;
    final sweep = 2 * pi * progress;
    canvas.drawArc(rect, startAngle, sweep, false, fg);

    if (progress > 0.02) {
      final endAngle = startAngle + sweep;
      final endOffset = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      );
      final tipShadow = Paint()
        ..color = CupertinoColors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(endOffset, strokeWidth / 2 + 0.5, tipShadow);
      final tipColor = g != null && g.isNotEmpty ? g.last : color;
      canvas.drawCircle(
        endOffset,
        strokeWidth / 2,
        Paint()..color = tipColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.gradient != gradient ||
      old.strokeWidth != strokeWidth;
}
