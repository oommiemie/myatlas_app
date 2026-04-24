import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

/// Minimal in-progress animations shown on the "measuring" step of
/// [showMeasureFromDeviceSheet]. Each kind keeps its own subtle motion
/// hint for the vital being measured, but with stripped-back geometry
/// (no grids, gauges, or digital readouts) so the flow feels calm.
enum MeasureAnimationKind {
  ecg,            // Heart rate — breathing circle + clean pulse wave
  pressureCuff,   // Blood pressure — concentric pulse rings
  thermometer,    // Temperature — vertical pill fill
  sugarDrop,      // Blood sugar — drop + ripples
  pulseOx,        // SpO₂ — soft glow circle + ppg
  scale,          // BMI — bouncing dot on a line
  tape,           // Waist — arc drawing around a ring
  sleep,          // Sleep — crescent moon + stars
}

class MeasureAnimation extends StatefulWidget {
  const MeasureAnimation({
    super.key,
    required this.kind,
    required this.color,
    this.size = 240,
  });

  final MeasureAnimationKind kind;
  final Color color;
  final double size;

  @override
  State<MeasureAnimation> createState() => _MeasureAnimationState();
}

class _MeasureAnimationState extends State<MeasureAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  Duration _durationFor(MeasureAnimationKind k) {
    switch (k) {
      case MeasureAnimationKind.ecg:
        return const Duration(milliseconds: 1200);
      case MeasureAnimationKind.pressureCuff:
        return const Duration(milliseconds: 2400);
      case MeasureAnimationKind.thermometer:
        return const Duration(milliseconds: 2800);
      case MeasureAnimationKind.sugarDrop:
        return const Duration(milliseconds: 1800);
      case MeasureAnimationKind.pulseOx:
        return const Duration(milliseconds: 1400);
      case MeasureAnimationKind.scale:
        return const Duration(milliseconds: 2400);
      case MeasureAnimationKind.tape:
        return const Duration(milliseconds: 2600);
      case MeasureAnimationKind.sleep:
        return const Duration(milliseconds: 3400);
    }
  }

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: _durationFor(widget.kind))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            return CustomPaint(
              painter: _MeasurePainter(
                kind: widget.kind,
                color: widget.color,
                t: _c.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MeasurePainter extends CustomPainter {
  _MeasurePainter({
    required this.kind,
    required this.color,
    required this.t,
  });

  final MeasureAnimationKind kind;
  final Color color;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case MeasureAnimationKind.ecg:
        _paintEcg(canvas, size);
        break;
      case MeasureAnimationKind.pressureCuff:
        _paintPressureCuff(canvas, size);
        break;
      case MeasureAnimationKind.thermometer:
        _paintThermometer(canvas, size);
        break;
      case MeasureAnimationKind.sugarDrop:
        _paintSugarDrop(canvas, size);
        break;
      case MeasureAnimationKind.pulseOx:
        _paintPulseOx(canvas, size);
        break;
      case MeasureAnimationKind.scale:
        _paintScale(canvas, size);
        break;
      case MeasureAnimationKind.tape:
        _paintTape(canvas, size);
        break;
      case MeasureAnimationKind.sleep:
        _paintSleep(canvas, size);
        break;
    }
  }

  // ── Shared background ──────────────────────────────────────────────────
  void _paintSoftBg(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(28)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(rect),
    );
  }

  // ── ECG — breathing dot + single sweeping pulse line ───────────────────
  void _paintEcg(Canvas canvas, Size size) {
    _paintSoftBg(canvas, size);
    final cy = size.height / 2;

    final path = Path();
    const samples = 180;
    for (int i = 0; i < samples; i++) {
      final u = i / (samples - 1);
      final x = u * size.width;
      final phase = (u - t + 1) % 1.0;
      double v = 0;
      if (phase > 0.05 && phase < 0.15) {
        final p = (phase - 0.05) / 0.10;
        v = math.sin(p * math.pi) * 0.7;
      }
      final y = cy - v * size.height * 0.22;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // ── Blood pressure — 3 concentric pulse rings ──────────────────────────
  void _paintPressureCuff(Canvas canvas, Size size) {
    _paintSoftBg(canvas, size);
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.shortestSide * 0.42;

    for (int i = 0; i < 3; i++) {
      final p = ((t + i / 3) % 1.0);
      final r = p * maxR;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = color.withValues(alpha: (1 - p) * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    final breath = 1 + math.sin(t * math.pi * 2) * 0.08;
    canvas.drawCircle(
      center,
      14 * breath,
      Paint()..color = color,
    );
  }

  // ── Thermometer — vertical pill fills up and down ──────────────────────
  void _paintThermometer(Canvas canvas, Size size) {
    _paintSoftBg(canvas, size);
    final cx = size.width / 2;
    final topY = size.height * 0.22;
    final bottomY = size.height * 0.78;
    const w = 24.0;

    final pill = RRect.fromLTRBR(
      cx - w / 2,
      topY,
      cx + w / 2,
      bottomY,
      const Radius.circular(w / 2),
    );
    canvas.drawRRect(
      pill,
      Paint()..color = color.withValues(alpha: 0.12),
    );

    final level = math.sin(t * math.pi).clamp(0.0, 1.0);
    final fillTop = topY + (bottomY - topY) * (1 - level);

    canvas.save();
    canvas.clipRRect(pill);
    canvas.drawRect(
      Rect.fromLTRB(cx - w / 2, fillTop, cx + w / 2, bottomY),
      Paint()..color = color,
    );
    canvas.restore();
  }

  // ── Sugar drop — drop falls then ripples expand ────────────────────────
  void _paintSugarDrop(Canvas canvas, Size size) {
    _paintSoftBg(canvas, size);
    final center = Offset(size.width / 2, size.height * 0.55);

    final fall = (t / 0.45).clamp(0.0, 1.0);
    final rippleT = t < 0.45 ? 0.0 : (t - 0.45) / 0.55;

    if (fall < 1) {
      final dy = fall * (size.height * 0.32);
      final dropCenter = Offset(center.dx, size.height * 0.23 + dy);
      final dropPath = Path()
        ..moveTo(dropCenter.dx, dropCenter.dy - 8)
        ..cubicTo(
          dropCenter.dx + 7, dropCenter.dy - 2,
          dropCenter.dx + 7, dropCenter.dy + 7,
          dropCenter.dx, dropCenter.dy + 7,
        )
        ..cubicTo(
          dropCenter.dx - 7, dropCenter.dy + 7,
          dropCenter.dx - 7, dropCenter.dy - 2,
          dropCenter.dx, dropCenter.dy - 8,
        )
        ..close();
      canvas.drawPath(dropPath, Paint()..color = color);
    } else {
      for (int i = 0; i < 3; i++) {
        final p = (rippleT + i / 3).clamp(0.0, 1.0);
        if (p <= 0) continue;
        canvas.drawCircle(
          center,
          p * size.shortestSide * 0.35,
          Paint()
            ..color = color.withValues(alpha: (1 - p) * 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
      canvas.drawCircle(
        center,
        4,
        Paint()..color = color.withValues(alpha: 1 - rippleT),
      );
    }
  }

  // ── Pulse ox — soft glow + tiny ppg wave ───────────────────────────────
  void _paintPulseOx(Canvas canvas, Size size) {
    _paintSoftBg(canvas, size);
    final center = Offset(size.width / 2, size.height * 0.45);
    final pulse = math.sin(t * math.pi * 2) * 0.5 + 0.5;

    canvas.drawCircle(
      center,
      size.shortestSide * 0.28,
      Paint()
        ..color = color.withValues(alpha: 0.08 + pulse * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      center,
      size.shortestSide * 0.12,
      Paint()..color = color.withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      center,
      size.shortestSide * 0.06 + pulse * 2,
      Paint()..color = color,
    );

    final wy = size.height * 0.8;
    final path = Path();
    const samples = 120;
    for (int i = 0; i < samples; i++) {
      final u = i / (samples - 1);
      final x = size.width * 0.18 + u * size.width * 0.64;
      final phase = (u - t + 1) % 1.0;
      double v = 0;
      if (phase > 0.05 && phase < 0.25) {
        final p = (phase - 0.05) / 0.20;
        v = math.sin(p * math.pi) * 0.5;
      }
      final y = wy - v * 16;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Scale — horizontal line + bouncing dot that settles ────────────────
  void _paintScale(Canvas canvas, Size size) {
    _paintSoftBg(canvas, size);
    final cx = size.width / 2;
    final lineY = size.height * 0.68;

    canvas.drawLine(
      Offset(size.width * 0.22, lineY),
      Offset(size.width * 0.78, lineY),
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    final bounce = math.sin(t * math.pi * 3) *
        math.exp(-t * 2.2) *
        size.height *
        0.22;
    final dotY = lineY - 14 - bounce.abs();
    canvas.drawCircle(
      Offset(cx, dotY),
      10,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      Offset(cx, dotY),
      8,
      Paint()..color = color,
    );
  }

  // ── Tape — thin ring drawing around + head dot ─────────────────────────
  void _paintTape(Canvas canvas, Size size) {
    _paintSoftBg(canvas, size);
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.34;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final sweep = t * math.pi * 2;
    if (sweep > 0.001) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    final angle = -math.pi / 2 + sweep;
    final head = Offset(
      center.dx + math.cos(angle) * r,
      center.dy + math.sin(angle) * r,
    );
    canvas.drawCircle(
      head,
      7,
      Paint()..color = CupertinoColors.white,
    );
    canvas.drawCircle(
      head,
      5,
      Paint()..color = color,
    );
  }

  // ── Sleep — crescent moon + few twinkling stars ────────────────────────
  void _paintSleep(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(28)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F1636), Color(0xFF1F2557)],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(28)),
    );

    final stars = [
      Offset(size.width * 0.18, size.height * 0.2),
      Offset(size.width * 0.82, size.height * 0.28),
      Offset(size.width * 0.28, size.height * 0.82),
      Offset(size.width * 0.78, size.height * 0.75),
      Offset(size.width * 0.5, size.height * 0.15),
    ];
    for (int i = 0; i < stars.length; i++) {
      final tw = (math.sin(t * math.pi * 2 + i * 1.4) + 1) / 2;
      canvas.drawCircle(
        stars[i],
        1.8,
        Paint()
          ..color = CupertinoColors.white
              .withValues(alpha: 0.35 + tw * 0.55),
      );
    }

    final center = Offset(size.width / 2, size.height / 2);
    final breath = 1 + math.sin(t * math.pi * 2) * 0.04;
    final mr = size.shortestSide * 0.2 * breath;

    final moon = Path()
      ..addOval(Rect.fromCircle(center: center, radius: mr));
    final cut = Path()
      ..addOval(Rect.fromCircle(
        center: center + Offset(mr * 0.38, -mr * 0.08),
        radius: mr * 0.92,
      ));
    final crescent = Path.combine(PathOperation.difference, moon, cut);

    canvas.drawPath(
      crescent,
      Paint()
        ..color = const Color(0xFFFFF1B8).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawPath(
      crescent,
      Paint()..color = const Color(0xFFFFF4C8),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MeasurePainter old) =>
      old.t != t || old.color != color || old.kind != kind;
}
