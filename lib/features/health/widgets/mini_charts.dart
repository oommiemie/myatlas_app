import 'dart:math';
import 'package:flutter/cupertino.dart';

const Duration _entryDuration = Duration(milliseconds: 900);
const Cubic _entryCurve = Cubic(0.22, 1.0, 0.36, 1.0);

Path _smoothPathThrough(List<Offset> points, {double tension = 1}) {
  final path = Path();
  if (points.isEmpty) return path;
  path.moveTo(points.first.dx, points.first.dy);
  if (points.length == 1) return path;
  for (int i = 0; i < points.length - 1; i++) {
    final p0 = i > 0 ? points[i - 1] : points[i];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = i + 2 < points.length ? points[i + 2] : p2;
    final c1 = Offset(
      p1.dx + (p2.dx - p0.dx) / 6 * tension,
      p1.dy + (p2.dy - p0.dy) / 6 * tension,
    );
    final c2 = Offset(
      p2.dx - (p3.dx - p1.dx) / 6 * tension,
      p2.dy - (p3.dy - p1.dy) / 6 * tension,
    );
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path;
}


class MiniLineChart extends StatefulWidget {
  const MiniLineChart({
    super.key,
    required this.data,
    required this.color,
    this.dates,
    this.indicatorIndex,
    this.showFill = true,
    this.smooth = true,
    this.showDots = false,
    this.unit = '',
    this.interactive = true,
    this.onTouch,
  });

  final List<double> data;
  final Color color;
  final List<DateTime>? dates;
  final int? indicatorIndex;
  final bool showFill;
  final bool smooth;
  final bool showDots;
  final String unit;
  final bool interactive;
  final ValueChanged<int?>? onTouch;

  @override
  State<MiniLineChart> createState() => _MiniLineChartState();
}

class _MiniLineChartState extends State<MiniLineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int? _touched;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _entryDuration)
      ..forward();
  }

  @override
  void didUpdateWidget(covariant MiniLineChart old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) {
      _ctrl
        ..reset()
        ..forward();
      _touched = null;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int? _nearestIndex(double localX, double width) {
    if (widget.data.isEmpty) return null;
    final slot = width / widget.data.length;
    return (localX / slot).floor().clamp(0, widget.data.length - 1);
  }

  void _setTouched(int? i) {
    if (i == _touched) return;
    setState(() => _touched = i);
    widget.onTouch?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.interactive
              ? (d) => _setTouched(_nearestIndex(d.localPosition.dx, width))
              : null,
          onTapCancel: () => _setTouched(null),
          onPanStart: widget.interactive
              ? (d) => _setTouched(_nearestIndex(d.localPosition.dx, width))
              : null,
          onPanUpdate: widget.interactive
              ? (d) => _setTouched(_nearestIndex(d.localPosition.dx, width))
              : null,
          onPanEnd: widget.interactive
              ? (_) => Future.delayed(
                  const Duration(milliseconds: 800),
                  () {
                    if (mounted) _setTouched(null);
                  },
                )
              : null,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final progress = _entryCurve.transform(_ctrl.value);
              final touched = _touched;
              return CustomPaint(
                painter: _LineChartPainter(
                  data: widget.data,
                  color: widget.color,
                  indicatorIndex: touched ?? widget.indicatorIndex,
                  showFill: widget.showFill,
                  smooth: widget.smooth,
                  showDots: widget.showDots,
                  progress: progress,
                ),
                size: Size.infinite,
              );
            },
          ),
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.color,
    required this.indicatorIndex,
    required this.showFill,
    required this.smooth,
    required this.showDots,
    required this.progress,
  });

  final List<double> data;
  final Color color;
  final int? indicatorIndex;
  final bool showFill;
  final bool smooth;
  final bool showDots;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final minV = data.reduce(min);
    final maxV = data.reduce(max);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
    final slot = size.width / data.length;
    const padY = 6.0;
    final plotH = size.height - padY * 2;

    final points = <Offset>[
      for (int i = 0; i < data.length; i++)
        Offset(
          i * slot + slot / 2,
          padY + plotH - ((data[i] - minV) / range) * plotH,
        ),
    ];

    final path = smooth
        ? _smoothPathThrough(points)
        : (Path()..moveTo(points.first.dx, points.first.dy)
          ..addPolygon([for (final p in points.skip(1)) p], false));

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, 0, size.width * progress, size.height),
    );

    if (showFill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.30), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size);
      canvas.drawPath(fillPath, fillPaint);
    }

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    if (showDots) {
      final dotFill = Paint()..color = const Color(0xFFFFFFFF);
      final dotStroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (final p in points) {
        canvas.drawCircle(p, 3.2, dotFill);
        canvas.drawCircle(p, 3.2, dotStroke);
      }
    }

    canvas.restore();

    final idx = indicatorIndex;
    if (idx != null && idx >= 0 && idx < points.length && progress > 0.95) {
      final p = points[idx];
      final dashPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..strokeWidth = 1.2;
      _drawDashedLine(canvas, Offset(p.dx, p.dy + 6),
          Offset(p.dx, size.height), dashPaint);
      canvas.drawCircle(p, 6,
          Paint()..color = color.withValues(alpha: 0.18));
      canvas.drawCircle(p, 4,
          Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawCircle(
          p,
          4,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dash = 3.0;
    const gap = 3.0;
    final total = (p2 - p1).distance;
    if (total == 0) return;
    final dir = (p2 - p1) / total;
    double covered = 0;
    while (covered < total) {
      final start = p1 + dir * covered;
      final end = p1 + dir * (covered + dash).clamp(0, total);
      canvas.drawLine(start, end, paint);
      covered += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.data != data ||
      old.color != color ||
      old.indicatorIndex != indicatorIndex ||
      old.showFill != showFill ||
      old.progress != progress;
}

class DualLineChart extends StatefulWidget {
  const DualLineChart({
    super.key,
    required this.primary,
    required this.secondary,
    required this.primaryColor,
    required this.secondaryColor,
    this.dates,
    this.primaryUnit = '',
    this.primaryLabel,
    this.secondaryLabel,
    this.interactive = true,
    this.onTouch,
  });

  final List<double> primary;
  final List<double> secondary;
  final Color primaryColor;
  final Color secondaryColor;
  final List<DateTime>? dates;
  final String primaryUnit;
  final String? primaryLabel;
  final String? secondaryLabel;
  final bool interactive;
  final ValueChanged<int?>? onTouch;

  @override
  State<DualLineChart> createState() => _DualLineChartState();
}

class _DualLineChartState extends State<DualLineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int? _touched;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _entryDuration)
      ..forward();
  }

  @override
  void didUpdateWidget(covariant DualLineChart old) {
    super.didUpdateWidget(old);
    if (old.primary != widget.primary || old.secondary != widget.secondary) {
      _ctrl
        ..reset()
        ..forward();
      _touched = null;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int? _nearest(double x, double width) {
    if (widget.primary.isEmpty) return null;
    final slot = width / widget.primary.length;
    return (x / slot).floor().clamp(0, widget.primary.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final painter = AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final progress = _entryCurve.transform(_ctrl.value);
            final touched = _touched;
            return CustomPaint(
              painter: _DualLinePainter(
                primary: widget.primary,
                secondary: widget.secondary,
                primaryColor: widget.primaryColor,
                secondaryColor: widget.secondaryColor,
                touchedIndex: touched,
                progress: progress,
              ),
              size: Size.infinite,
            );
          },
        );
        if (!widget.interactive) return painter;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _setTouched(_nearest(d.localPosition.dx, width)),
          onTapCancel: () => _setTouched(null),
          onPanStart: (d) => _setTouched(_nearest(d.localPosition.dx, width)),
          onPanUpdate: (d) => _setTouched(_nearest(d.localPosition.dx, width)),
          onPanEnd: (_) => Future.delayed(
            const Duration(milliseconds: 800),
            () {
              if (mounted) _setTouched(null);
            },
          ),
          child: painter,
        );
      },
    );
  }

  void _setTouched(int? i) {
    if (i == _touched) return;
    setState(() => _touched = i);
    widget.onTouch?.call(i);
  }
}

class _DualLinePainter extends CustomPainter {
  _DualLinePainter({
    required this.primary,
    required this.secondary,
    required this.primaryColor,
    required this.secondaryColor,
    required this.touchedIndex,
    required this.progress,
  });

  final List<double> primary;
  final List<double> secondary;
  final Color primaryColor;
  final Color secondaryColor;
  final int? touchedIndex;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, 0, size.width * progress, size.height),
    );
    _drawCurve(canvas, size, primary, primaryColor);
    _drawCurve(canvas, size, secondary, secondaryColor);
    canvas.restore();

    final idx = touchedIndex;
    if (idx != null && progress > 0.95) {
      _drawTouchIndicator(canvas, size, primary, primaryColor, idx);
      _drawTouchIndicator(canvas, size, secondary, secondaryColor, idx);
      final dash = Paint()
        ..color = CupertinoColors.black.withValues(alpha: 0.15)
        ..strokeWidth = 1;
      final slot = size.width / primary.length;
      final x = idx * slot + slot / 2;
      _dashedLine(canvas, Offset(x, 0), Offset(x, size.height), dash);
    }
  }

  void _drawCurve(
      Canvas canvas, Size size, List<double> data, Color color) {
    if (data.isEmpty) return;
    final minV = data.reduce(min);
    final maxV = data.reduce(max);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
    final slot = size.width / data.length;
    const pad = 6.0;
    final plotH = size.height - pad * 2;

    final points = <Offset>[
      for (int i = 0; i < data.length; i++)
        Offset(
          i * slot + slot / 2,
          pad + plotH - ((data[i] - minV) / range) * plotH,
        ),
    ];

    canvas.drawPath(
      _smoothPathThrough(points),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawTouchIndicator(Canvas canvas, Size size, List<double> data,
      Color color, int idx) {
    if (data.isEmpty || idx >= data.length) return;
    final minV = data.reduce(min);
    final maxV = data.reduce(max);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
    final slot = size.width / data.length;
    const pad = 6.0;
    final plotH = size.height - pad * 2;
    final p = Offset(
        idx * slot + slot / 2,
        pad + plotH - ((data[idx] - minV) / range) * plotH);
    canvas.drawCircle(p, 5, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawCircle(
        p,
        5,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2);
  }

  void _dashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dash = 3.0;
    const gap = 3.0;
    final total = (p2 - p1).distance;
    if (total == 0) return;
    final dir = (p2 - p1) / total;
    double covered = 0;
    while (covered < total) {
      final s = p1 + dir * covered;
      final e = p1 + dir * (covered + dash).clamp(0, total);
      canvas.drawLine(s, e, paint);
      covered += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DualLinePainter old) =>
      old.primary != primary ||
      old.secondary != secondary ||
      old.touchedIndex != touchedIndex ||
      old.progress != progress;
}

class MiniBarChart extends StatefulWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    required this.color,
    this.dates,
    this.highlightIndex,
    this.highlightColor,
    this.barWidth = 6,
    this.rounded = true,
    this.unit = '',
    this.interactive = true,
    this.dimAlpha = 0.2,
    this.useDimGradient = false,
    this.dimGradient = const [Color(0xFFB9E6FE), Color(0xFF36BFFA)],
    this.onTouch,
  });

  final List<double> values;
  final Color color;
  final List<DateTime>? dates;
  final int? highlightIndex;
  final Color? highlightColor;
  final double barWidth;
  final bool rounded;
  final String unit;
  final ValueChanged<int?>? onTouch;
  final bool interactive;
  final double dimAlpha;
  final bool useDimGradient;
  final List<Color> dimGradient;

  @override
  State<MiniBarChart> createState() => _MiniBarChartState();
}

class _MiniBarChartState extends State<MiniBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int? _touched;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _entryDuration)
      ..forward();
  }

  @override
  void didUpdateWidget(covariant MiniBarChart old) {
    super.didUpdateWidget(old);
    if (old.values != widget.values) {
      _ctrl
        ..reset()
        ..forward();
      _touched = null;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int? _nearest(double x, double width) {
    if (widget.values.isEmpty) return null;
    final slot = width / widget.values.length;
    return (x / slot).floor().clamp(0, widget.values.length - 1);
  }

  void _setTouched(int? i) {
    if (i == _touched) return;
    setState(() => _touched = i);
    widget.onTouch?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.interactive
              ? (d) => _setTouched(_nearest(d.localPosition.dx, width))
              : null,
          onTapCancel: () => _setTouched(null),
          onPanEnd: widget.interactive
              ? (_) => Future.delayed(
                  const Duration(milliseconds: 800),
                  () {
                    if (mounted) _setTouched(null);
                  },
                )
              : null,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final progress = _entryCurve.transform(_ctrl.value);
              final touched = _touched;
              return CustomPaint(
                painter: _BarPainter(
                  values: widget.values,
                  color: widget.color,
                  highlightIndex: touched ?? widget.highlightIndex,
                  highlightColor: widget.highlightColor ?? widget.color,
                  barWidth: widget.barWidth,
                  rounded: widget.rounded,
                  progress: progress,
                  dimAlpha: widget.dimAlpha,
                  useDimGradient: widget.useDimGradient,
                  dimGradient: widget.dimGradient,
                ),
                size: Size.infinite,
              );
            },
          ),
        );
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.values,
    required this.color,
    required this.highlightIndex,
    required this.highlightColor,
    required this.barWidth,
    required this.rounded,
    required this.progress,
    required this.dimAlpha,
    required this.useDimGradient,
    required this.dimGradient,
  });

  final List<double> values;
  final Color color;
  final int? highlightIndex;
  final Color highlightColor;
  final double barWidth;
  final bool rounded;
  final double progress;
  final double dimAlpha;
  final bool useDimGradient;
  final List<Color> dimGradient;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce(max);
    final slot = size.width / values.length;
    final radius = rounded ? Radius.circular(barWidth / 2) : Radius.zero;
    for (int i = 0; i < values.length; i++) {
      final h = maxV == 0
          ? 0.0
          : (values[i] / maxV) * size.height * progress;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * slot + (slot - barWidth) / 2,
          size.height - h,
          barWidth,
          h,
        ),
        radius,
      );
      final isHighlight = i == highlightIndex;
      final paint = Paint();
      if (isHighlight) {
        paint.color = highlightColor;
      } else if (useDimGradient && h > 0) {
        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dimGradient,
        ).createShader(rect.outerRect);
      } else {
        paint.color = color.withValues(alpha: dimAlpha);
      }
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.values != values ||
      old.color != color ||
      old.highlightIndex != highlightIndex ||
      old.highlightColor != highlightColor ||
      old.progress != progress ||
      old.dimAlpha != dimAlpha ||
      old.useDimGradient != useDimGradient;
}

class PillBarChart extends StatefulWidget {
  const PillBarChart({
    super.key,
    required this.values,
    required this.color,
    this.dates,
    this.barWidth = 8,
    this.unit = '',
    this.interactive = true,
    this.onTouch,
  });

  final List<double> values;
  final Color color;
  final List<DateTime>? dates;
  final double barWidth;
  final String unit;
  final bool interactive;
  final ValueChanged<int?>? onTouch;

  @override
  State<PillBarChart> createState() => _PillBarChartState();
}

class _PillBarChartState extends State<PillBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int? _touched;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _entryDuration)
      ..forward();
  }

  @override
  void didUpdateWidget(covariant PillBarChart old) {
    super.didUpdateWidget(old);
    if (old.values != widget.values) {
      _ctrl
        ..reset()
        ..forward();
      _touched = null;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int? _nearest(double x, double width) {
    if (widget.values.isEmpty) return null;
    final slot = width / widget.values.length;
    return (x / slot).floor().clamp(0, widget.values.length - 1);
  }

  void _setTouched(int? i) {
    if (i == _touched) return;
    setState(() => _touched = i);
    widget.onTouch?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.interactive
              ? (d) => _setTouched(_nearest(d.localPosition.dx, width))
              : null,
          onTapCancel: () => _setTouched(null),
          onPanEnd: widget.interactive
              ? (_) => Future.delayed(
                  const Duration(milliseconds: 800),
                  () {
                    if (mounted) _setTouched(null);
                  },
                )
              : null,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final progress = _entryCurve.transform(_ctrl.value);
              final touched = _touched;
              return CustomPaint(
                painter: _PillBarPainter(
                  values: widget.values,
                  color: widget.color,
                  barWidth: widget.barWidth,
                  highlightIndex: touched,
                  progress: progress,
                ),
                size: Size.infinite,
              );
            },
          ),
        );
      },
    );
  }
}

class _PillBarPainter extends CustomPainter {
  _PillBarPainter({
    required this.values,
    required this.color,
    required this.barWidth,
    required this.highlightIndex,
    required this.progress,
  });

  final List<double> values;
  final Color color;
  final double barWidth;
  final int? highlightIndex;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce(max);
    final slot = size.width / values.length;
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.20)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length; i++) {
      final centerX = i * slot + slot / 2;
      canvas.drawLine(
        Offset(centerX, 2),
        Offset(centerX, size.height - 2),
        trackPaint,
      );

      final minBar = barWidth;
      final full = maxV == 0 ? minBar : (values[i] / maxV) * (size.height - 4);
      final barH =
          (full.clamp(minBar, size.height - 4).toDouble()) * progress;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - barWidth / 2,
          size.height - barH - 2,
          barWidth,
          barH,
        ),
        Radius.circular(barWidth / 2),
      );
      final isHighlight = i == highlightIndex;
      canvas.drawRRect(
        rect,
        Paint()
          ..color = isHighlight ? color : color.withValues(alpha: 0.85),
      );
      if (isHighlight) {
        canvas.drawRRect(
          rect.inflate(2),
          Paint()
            ..color = color.withValues(alpha: 0.20)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PillBarPainter old) =>
      old.values != values ||
      old.color != color ||
      old.highlightIndex != highlightIndex ||
      old.progress != progress;
}

class BmiGauge extends StatefulWidget {
  const BmiGauge({
    super.key,
    required this.value,
    this.min = 15,
    this.max = 35,
    required this.color,
  });

  final double value;
  final double min;
  final double max;
  final Color color;

  @override
  State<BmiGauge> createState() => _BmiGaugeState();
}

class _BmiGaugeState extends State<BmiGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _entryDuration)
      ..forward();
  }

  @override
  void didUpdateWidget(covariant BmiGauge old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        ((widget.value - widget.min) / (widget.max - widget.min))
            .clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _entryCurve.transform(_ctrl.value);
        return CustomPaint(
          painter: _BmiGaugePainter(progress: progress * t),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BmiGaugePainter extends CustomPainter {
  _BmiGaugePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = min(size.width / 2, size.height) - 8;
    const stroke = 12.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = const Color(0xFFECECEC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, pi, pi, false, track);

    final gradient = SweepGradient(
      startAngle: pi,
      endAngle: 2 * pi,
      colors: const [
        Color(0xFFFFE14D),
        Color(0xFFB8DE4A),
        Color(0xFF34C759),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final fg = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, pi, pi * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _BmiGaugePainter old) =>
      old.progress != progress;
}

