import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/liquid_glass_button.dart';
import '../../nutrition/data/meal_store.dart';

class MealCard extends StatefulWidget {
  const MealCard({
    super.key,
    required this.tagline,
    required this.name,
    required this.calories,
    required this.target,
    required this.meals,
    this.onScan,
  });

  final String tagline;
  final String name;
  final int calories; // consumed today
  final int target; // daily target
  final int meals; // meals eaten
  final VoidCallback? onScan;

  static const _primary600 = Color(0xFF1D8B6B);
  static const _primary900 = Color(0xFF093327);
  static const _borderDefault = Color(0xFFE5E5E5);
  static const _textSecondary = Color(0xFF3E453F);
  static const _neutral500 = Color(0xFF737373);

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Latest meal (most recent by time) for the "มื้อล่าสุด" stat.
    final entries = MealStore.instance.meals.value;
    MealEntry? latest;
    for (final m in entries) {
      if (latest == null || m.time.isAfter(latest.time)) latest = m;
    }
    final latestKcal = latest?.calories ?? 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: [0.164, 1.0],
            colors: [MealCard._primary600, MealCard._primary900],
          ),
          border: Border.all(color: MealCard._borderDefault, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 1,
            ),
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -36,
              top: -22,
              width: 130,
              height: 130,
              child: _AnimatedSalad(entryCtrl: _entryCtrl),
            ),
            Column(
              children: [
                _TopRow(
                  tagline: widget.tagline,
                  name: widget.name,
                  onScan: widget.onScan,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: MealCard._borderDefault, width: 0.5),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Calorie ring — center shows kcal left, fill =
                        // consumed / target.
                        _CalorieRing(
                          consumed: widget.calories,
                          target: widget.target,
                          progress: _entryCtrl,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _MiniStat(
                                      iconBg: const Color(0xFFFF6B3D),
                                      icon: CupertinoIcons.flame_fill,
                                      label: 'มื้อล่าสุด',
                                      value: _fmt(latestKcal),
                                      unit: 'kcal',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 1,
                                    height: 32,
                                    color: MealCard._borderDefault,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _MiniStat(
                                      iconBg: MealCard._primary600,
                                      icon: Icons.restaurant,
                                      iconSize: 10,
                                      label: 'มื้ออาหาร',
                                      value: '${widget.meals}',
                                      unit: 'มื้อ',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // AI scan quota — under the stats, same column.
                              const _AiQuotaBar(used: 1, total: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSalad extends StatelessWidget {
  const _AnimatedSalad({required this.entryCtrl});

  final AnimationController entryCtrl;

  static const double _baseAngle = 22.11 * pi / 180;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entryCtrl,
      builder: (_, child) {
        final t = entryCtrl.value.clamp(0.0, 1.0);
        final entry = Curves.easeOutBack.transform(t);
        final fadeIn = Curves.easeOut.transform(t);
        final entryDx = (1 - entry) * -36;
        final entryDy = (1 - entry) * -44;
        final entryScale = 0.55 + 0.45 * entry;

        return Transform.translate(
          offset: Offset(entryDx, entryDy),
          child: Transform.rotate(
            angle: _baseAngle,
            child: Transform.scale(
              scale: entryScale,
              child: Opacity(opacity: fadeIn, child: child),
            ),
          ),
        );
      },
      child: Image.asset(
        'assets/images/salad.png',
        width: 130,
        height: 130,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.tagline,
    required this.name,
    required this.onScan,
  });

  final String tagline;
  final String name;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(90, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tagline,
                  style: AppTypography.caption2(
                    CupertinoColors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: AppTypography.subheadline(
                    CupertinoColors.white.withValues(alpha: 0.95),
                  ).copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          LiquidGlassButton(
            icon: CupertinoIcons.camera_fill,
            onTap: onScan,
          ),
        ],
      ),
    );
  }
}


/// Clear daily AI-scan quota: label + "เหลือ X/Y ครั้ง" + a battery-style bar
/// (full = plenty of scans left). Replaces the cryptic "1/16".
class _AiQuotaBar extends StatelessWidget {
  const _AiQuotaBar({required this.used, required this.total});

  final int used;
  final int total;

  // Teal — harmonises with the card's green palette.
  static const _accent = Color(0xFF0D9488);
  static const _disabled = Color(0xFFA3A3A3);

  @override
  Widget build(BuildContext context) {
    final remaining = (total - used).clamp(0, total);
    final frac = total == 0 ? 0.0 : (remaining / total).clamp(0.0, 1.0);
    // No scans left → grey everything out (disabled).
    final out = remaining == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'สแกนอาหารด้วย AI วันนี้',
                style: AppTypography.caption2(
                    out ? _disabled : MealCard._textSecondary),
              ),
            ),
            Text(
              out ? 'ครบโควต้าแล้ว' : '$remaining/$total ครั้ง',
              style: AppTypography.caption2(out ? _disabled : _accent).copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(color: out
                    ? const Color(0xFFE5E5E5)
                    : const Color(0xFFD6F3EF)),
                FractionallySizedBox(
                  widthFactor: frac,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _fmt(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// Calorie progress ring (fill = consumed/target). Center shows kcal LEFT.
class _CalorieRing extends StatelessWidget {
  const _CalorieRing({
    required this.consumed,
    required this.target,
    required this.progress,
  });

  final int consumed;
  final int target;
  final Animation<double> progress;

  static const _size = 96.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: AnimatedBuilder(
        animation: progress,
        builder: (_, __) {
          final t = Curves.easeOutCubic.transform(progress.value.clamp(0, 1));
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(_size),
                painter: _MacroDonutPainter(t),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _fmt(consumed),
                    style: AppTypography.callout(CupertinoColors.black).copyWith(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '/ ${_fmt(target)} kcal',
                    style: AppTypography.caption2(MealCard._neutral500)
                        .copyWith(fontSize: 9),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

}

/// Macro-split donut (carbs/protein/fat) — same graph as the energy intake
/// card. [t] animates the segments growing in.
class _MacroDonutPainter extends CustomPainter {
  _MacroDonutPainter(this.t);
  final double t;

  // 5 main nutrients (from "สารอาหารหลัก"): carbs / protein / fat / sugar / fiber.
  // 5 main nutrients (from "สารอาหารหลัก"): carbs / protein / fat / sugar / fiber.
  static const _fracs = [0.55, 0.20, 0.12, 0.08, 0.05];
  static const _colors = [
    Color(0xFF22C55E), // คาร์โบไฮเดรต
    Color(0xFF3B82F6), // โปรตีน
    Color(0xFFF59E0B), // ไขมัน
    Color(0xFFA855F7), // น้ำตาล
    Color(0xFFEF4444), // ใยอาหาร
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 5;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE9EFEC);
    canvas.drawCircle(center, radius, track);

    const twoPi = 6.2831853;
    const gap = 0.10;
    var start = -1.5708 + gap / 2;
    for (var i = 0; i < _fracs.length; i++) {
      final full = _fracs[i] * twoPi;
      final sweep = (full - gap) * t.clamp(0.0, 1.0);
      if (sweep > 0) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = _colors[i];
        canvas.drawArc(rect, start, sweep, false, paint);
      }
      start += full;
    }
  }

  @override
  bool shouldRepaint(covariant _MacroDonutPainter old) => old.t != t;
}

/// Compact left-aligned stat: small icon + label, then value + unit.
class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.unit,
    this.iconSize = 9,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String value;
  final String unit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              alignment: Alignment.center,
              child: Icon(icon, size: iconSize, color: CupertinoColors.white),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.caption2(MealCard._textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTypography.callout(CupertinoColors.black).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.6,
                height: 1,
              ),
            ),
            const SizedBox(width: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                unit,
                style: AppTypography.caption2(MealCard._neutral500)
                    .copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
