import 'package:flutter/material.dart';

class DecorativeElements extends StatelessWidget {
  final double size;

  const DecorativeElements({super.key, this.size = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DecorativeElementsPainter()),
    );
  }
}

class _DecorativeElementsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 240;
    final center = Offset(120 * scale, 120 * scale);

    canvas.drawCircle(
      center,
      120 * scale,
      Paint()..color = const Color(0xFFD9F0FC).withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      Offset(121.75 * scale, 119.75 * scale),
      98.25 * scale,
      Paint()..color = const Color(0xFFD9F0FC),
    );
    canvas.drawCircle(
      Offset(121.55 * scale, 119.55 * scale),
      76.5 * scale,
      Paint()..color = const Color(0xFFE7F5FD),
    );
    canvas.drawCircle(
      Offset(122.5 * scale, 120.5 * scale),
      50.5 * scale,
      Paint()..color = const Color(0xFFFFFDF0),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EllipseGlow extends StatelessWidget {
  final double size;

  const EllipseGlow({super.key, this.size = 147});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _EllipseGlowPainter()),
    );
  }
}

class _EllipseGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.8),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawCircle(center, radius * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
