import 'dart:math';

import 'package:flutter/material.dart';

import '../water_detail_screen.dart';

/// Daily water-intake tracker with a circular gauge and a water-drop that fills
/// up as the user logs intake.
///
/// The user sets a daily goal (litres) and how many millilitres each glass
/// holds. The "ดื่ม" button stamps one glass; the small button removes one.
class HomeWaterIntakeCard extends StatefulWidget {
  const HomeWaterIntakeCard({
    super.key,
    this.initialGoalMl = 2500,
    this.initialMlPerGlass = 300,
    this.initialGlasses = 0,
  });

  /// Daily goal in millilitres.
  final int initialGoalMl;

  /// Volume of one glass in millilitres.
  final int initialMlPerGlass;

  /// Glasses already drunk when the card first appears.
  final int initialGlasses;

  @override
  State<HomeWaterIntakeCard> createState() => _HomeWaterIntakeCardState();
}

class _HomeWaterIntakeCardState extends State<HomeWaterIntakeCard> {
  static const _ink = Color(0xFF1A1A2E);
  static const _waterTop = Color(0xFF4FC3F7);
  static const _waterBottom = Color(0xFF1E88E5);

  late int _goalMl;
  late int _mlPerGlass;
  late int _drunk; // number of glasses stamped

  @override
  void initState() {
    super.initState();
    _goalMl = widget.initialGoalMl;
    _mlPerGlass = widget.initialMlPerGlass;
    _drunk = widget.initialGlasses;
  }

  int get _glassCount => (_goalMl / _mlPerGlass).ceil();
  int get _consumedMl => _drunk * _mlPerGlass;
  double get _progress => (_consumedMl / _goalMl).clamp(0.0, 1.0);

  String get _litres {
    final l = _goalMl / 1000;
    return l == l.roundToDouble() ? l.toStringAsFixed(0) : l.toStringAsFixed(1);
  }

  void _add() {
    if (_drunk < _glassCount) setState(() => _drunk++);
  }

  void _remove() {
    if (_drunk > 0) setState(() => _drunk--);
  }

  // Open the shared drink-settings sheet straight from the card (footer tap),
  // without going through the detail screen / chevron.
  void _openWaterSettings() {
    showWaterSettingsSheet(
      context: context,
      goalMl: _goalMl,
      mlPerGlass: _mlPerGlass,
      onSaved: (goal, perGlass) {
        setState(() {
          _goalMl = goal;
          _mlPerGlass = perGlass;
          if (_drunk > _glassCount) _drunk = _glassCount;
        });
      },
    );
  }

  void _openDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WaterDetailScreen(
          goalMl: _goalMl,
          mlPerGlass: _mlPerGlass,
          consumedMl: _consumedMl,
          onSettingsChanged: (goal, perGlass) {
            setState(() {
              _goalMl = goal;
              _mlPerGlass = perGlass;
              if (_drunk > _glassCount) _drunk = _glassCount;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Outer stacked-card shell: holds the white water card + the settings
      // button section beneath it as one grouped card. Blue shows only below
      // the white card (settings area) — flush on top/left/right.
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        // Pale blue (same as the remove-glass button) — calm, not a CTA.
        color: const Color(0xFFEFF6FA),
        border: Border.all(color: const Color(0xFFD9E8F0)),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
        GestureDetector(
      onTap: _openDetail,
      behavior: HitTestBehavior.opaque,
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_waterTop, _waterBottom],
                  ),
                ),
                child: const Icon(Icons.water_drop,
                    color: Colors.white, size: 13),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ดื่มน้ำวันนี้',
                  // Match the "กิจกรรม" header (size 12, w400, grey).
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.275,
                    color: Color(0xFF6D756E),
                    height: 1.33,
                  ),
                ),
              ),
              // Navigate affordance — the whole card opens the detail screen.
              const Icon(Icons.chevron_right,
                  size: 22, color: Color(0xFF8A97A3)),
            ],
          ),
          const SizedBox(height: 6),
          // Gauge + filling water drop + amount.
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _progress),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutCubic,
                    builder: (_, p, __) => CustomPaint(
                      size: const Size.square(220),
                      painter: _GaugePainter(p),
                    ),
                  ),
                  // Drop centered in the gauge.
                  _WaterDrop(
                    progress: _progress,
                    complete: _consumedMl >= _goalMl,
                  ),
                  // Amount sits in the gauge's open bottom gap.
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatMl(_consumedMl),
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '/${_formatMl(_goalMl)} มล.',
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A97A3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Controls: big "ดื่ม" button + small remove button.
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _add,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                        colors: [_waterTop, _waterBottom],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _waterBottom.withValues(alpha: 0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.water_drop,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'ดื่ม ($_mlPerGlass มล.)',
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _remove,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEFF6FA),
                    border: Border.all(color: const Color(0xFFD9E8F0)),
                  ),
                  child: const Icon(Icons.remove,
                      color: _waterBottom, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'แตะ "ดื่ม" เพื่อบันทึก · แก้วละ $_mlPerGlass มล. · เป้าหมาย $_litres ลิตร',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'IBM Plex Sans Thai Looped',
              fontSize: 11,
              color: Color(0xFF8A97A3),
            ),
          ),
        ],
      ),
      ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: _WaterSettingsButton(onTap: _openWaterSettings),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }

  static String _formatMl(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

/// Teardrop path shared by the water and bubble painters.
Path _teardropPath(Size size) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  final rb = w / 2;
  final cyBulb = h - rb;
  return Path()
    ..moveTo(cx, 0)
    ..quadraticBezierTo(cx + rb * 0.95, cyBulb - rb * 0.55, cx + rb, cyBulb)
    ..arcToPoint(Offset(cx - rb, cyBulb),
        radius: Radius.circular(rb), clockwise: true)
    ..quadraticBezierTo(cx - rb * 0.95, cyBulb - rb * 0.55, cx, 0)
    ..close();
}

/// A teardrop that fills with water (with a small wave) to [progress]. When
/// [complete], bubbles float up inside the drop and — once they finish — a
/// check mark pops in.
class _WaterDrop extends StatefulWidget {
  const _WaterDrop({required this.progress, required this.complete});
  final double progress;
  final bool complete;

  @override
  State<_WaterDrop> createState() => _WaterDropState();
}

class _WaterDropState extends State<_WaterDrop>
    with SingleTickerProviderStateMixin {
  // Drives the celebration: bubbles rise over the first ~70%, the check pops
  // in over the last ~30%.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.complete) _c.value = 1; // already complete on first build
  }

  @override
  void didUpdateWidget(_WaterDrop old) {
    super.didUpdateWidget(old);
    if (widget.complete && !old.complete) {
      _c.forward(from: 0);
    } else if (!widget.complete && old.complete) {
      _c.reset();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 98,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Water level rises smoothly toward the current progress.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: widget.progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, p, __) => CustomPaint(
              size: const Size(80, 98),
              painter: _DropWaterPainter(p),
            ),
          ),
          // Bubbles + check (only while/after complete).
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final v = _c.value;
              final check =
                  Curves.easeOutBack.transform(((v - 0.78) / 0.22).clamp(0.0, 1.0));
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.complete && v < 0.84)
                    CustomPaint(
                      size: const Size(80, 98),
                      painter: _BubblesPainter(v),
                    ),
                  if (check > 0)
                    Opacity(
                      opacity: check.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: check,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E88E5)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 26,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Bubbles rising inside the drop during the completion celebration.
class _BubblesPainter extends CustomPainter {
  _BubblesPainter(this.t);
  final double t; // controller value 0..1

  // [xFraction, phaseOffset, radius, ceilingFraction, lifespan]
  //  - ceilingFraction: where (as a fraction of height from the top) the bubble
  //    pops, so bubbles vanish at different heights rather than piling up.
  //  - lifespan: how long its rise takes (staggers when each pops).
  static const _bubbles = [
    [0.30, 0.00, 2.8, 0.34, 0.62],
    [0.50, 0.00, 4.0, 0.24, 0.72],
    [0.70, 0.04, 2.8, 0.40, 0.60],
    [0.40, 0.10, 3.2, 0.30, 0.66],
    [0.60, 0.08, 3.0, 0.46, 0.58],
    [0.50, 0.16, 3.6, 0.32, 0.70],
    [0.34, 0.22, 2.4, 0.52, 0.55],
    [0.66, 0.20, 2.6, 0.42, 0.62],
    [0.44, 0.28, 3.0, 0.36, 0.60],
    [0.58, 0.32, 2.6, 0.54, 0.56],
    [0.50, 0.40, 3.0, 0.40, 0.55],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final bubblesPhase = (t / 0.78).clamp(0.0, 1.0);
    canvas.save();
    canvas.clipPath(_teardropPath(size));

    final w = size.width;
    final h = size.height;
    final bottomY = h * 0.90;
    final paint = Paint();

    for (final b in _bubbles) {
      final phase = b[1];
      final lifespan = b[4];
      // Local progress 0..1 over this bubble's own lifespan.
      final local = ((bubblesPhase - phase) / lifespan);
      if (local <= 0 || local >= 1) continue;

      final ceilY = h * b[3];
      final y = bottomY - local * (bottomY - ceilY);
      final x = w * b[0] + sin(local * 2 * pi * 1.2 + phase * 12) * 3;

      final fadeIn = (local / 0.18).clamp(0.0, 1.0);
      final fadeOut = ((1 - local) / 0.30).clamp(0.0, 1.0);
      final op = min(fadeIn, fadeOut) * 0.82;
      final r = b[2] * (0.7 + 0.3 * local) * (0.45 + 0.55 * fadeOut);

      paint.color = Colors.white.withValues(alpha: op);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BubblesPainter old) => old.t != t;
}

class _DropWaterPainter extends CustomPainter {
  _DropWaterPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final drop = _teardropPath(size);
    canvas.save();
    canvas.clipPath(drop);

    // Empty (unfilled) tint.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE6F3FB),
    );

    // Water with a gentle wave on top.
    final level = size.height * (1 - progress);
    final wave = Path()..moveTo(0, level);
    const amp = 3.0;
    const waves = 1.6;
    for (double x = 0; x <= size.width; x += 2) {
      final y = level + sin((x / size.width) * 2 * pi * waves) * amp;
      wave.lineTo(x, y);
    }
    wave
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final water = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4FC3F7), Color(0xFF1E88E5)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(wave, water);
    canvas.restore();

    // Outline.
    canvas.drawPath(
      drop,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFB9DEF0),
    );
  }

  @override
  bool shouldRepaint(covariant _DropWaterPainter old) =>
      old.progress != progress;
}

/// Circular gauge: thick track + blue progress arc with tick marks (270° sweep,
/// gap at the bottom).
class _GaugePainter extends CustomPainter {
  _GaugePainter(this.progress);
  final double progress;

  static const double _start = 135 * pi / 180;
  static const double _sweep = 270 * pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 12;
    final rect = Rect.fromCircle(center: center, radius: r);

    final track = Paint()
      ..color = const Color(0xFFE6EEF3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep, false, track);

    final p = progress.clamp(0.0, 1.0);
    final fg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4FC3F7), Color(0xFF1E88E5)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    if (p > 0) canvas.drawArc(rect, _start, _sweep * p, false, fg);

    // Tick marks just inside the arc.
    const n = 36;
    final r1 = r - 12;
    final r2 = r - 19;
    for (var i = 0; i <= n; i++) {
      final t = i / n;
      final a = _start + _sweep * t;
      final cosA = cos(a);
      final sinA = sin(a);
      final tick = Paint()
        ..color = t <= p ? const Color(0xFF1E88E5) : const Color(0xFFCFDEE8)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center + Offset(cosA * r1, sinA * r1),
        center + Offset(cosA * r2, sinA * r2),
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.progress != progress;
}

/// Full-width blue "ตั้งค่าการดื่มน้ำ" button shown below the water card —
/// opens the drink-settings sheet. Separate from the card's chevron (detail).
class _WaterSettingsButton extends StatelessWidget {
  const _WaterSettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 44,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, color: Color(0xFF1E88E5), size: 18),
            SizedBox(width: 8),
            Text(
              'ตั้งค่าการดื่มน้ำ',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Thai Looped',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E88E5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
