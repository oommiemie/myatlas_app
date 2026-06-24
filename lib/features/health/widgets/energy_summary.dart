import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../data/health_data.dart';

/// "พลังงานวันนี้" — energy in vs out:
///  • intake card: total kcal eaten + macro donut (carbs/protein/fat)
///  • burned card: total kcal out (active energy) + steps/move/exercise
///  • net card: in − out result
class EnergySummarySection extends StatelessWidget {
  const EnergySummarySection({super.key, required this.data});
  final HealthData data;


  int _latest(WeeklySeries s) =>
      s.values.isEmpty ? 0 : s.values[s.latestIndex].round();

  @override
  Widget build(BuildContext context) {
    final inKcal = data.meal.calories;
    final steps = _latest(data.steps);
    final moveKcal = data.activity.move;
    final exerciseMin = data.activity.exercise;
    // "เผาผลาญ" total = the Move ring (active kcal). Same metric as เคลื่อนไหว,
    // so the headline stays consistent with the breakdown below.
    final outKcal = moveKcal;

    return _BurnedCard(
      inKcal: inKcal,
      burned: outKcal,
      steps: steps,
      moveKcal: moveKcal,
      exerciseMin: exerciseMin,
    );
  }
}

// ── shared bits ──────────────────────────────────────────────────────────────

const _ink = Color(0xFF1A1A2E);
const _grey = Color(0xFF6D756E);
const _muted = Color(0xFF8A97A3);

String _fmt(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// Numbers rendered in Nunito (digits only); Thai falls back to the app font.
/// Drives the variable wght axis so the weight actually applies.
TextStyle numFont(TextStyle base) => base.copyWith(
      fontFamily: 'Nunito',
      fontFamilyFallback: const ['IBM Plex Sans Thai Looped'],
      fontVariations: [
        FontVariation('wght', (base.fontWeight ?? FontWeight.w400).value.toDouble()),
      ],
    );

BoxDecoration _cardDeco() => BoxDecoration(
      color: CupertinoColors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: CupertinoColors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

Widget _cardHeader(IconData icon, Color color, String title) => Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Icon(icon, size: 12, color: CupertinoColors.white),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ],
    );

// ── Burned card ──────────────────────────────────────────────────────────────

class _BurnedCard extends StatelessWidget {
  const _BurnedCard({
    required this.inKcal,
    required this.burned,
    required this.steps,
    required this.moveKcal,
    required this.exerciseMin,
  });
  final int inKcal;
  final int burned;
  final int steps;
  final int moveKcal;
  final int exerciseMin;

  static const _inColor = Color(0xFF1D8B6B);
  static const _outColor = Color(0xFFFF6B3D);

  @override
  Widget build(BuildContext context) {
    final net = inKcal - burned;
    const netColor = _ink;

    return Container(
      decoration: _cardDeco(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
              CupertinoIcons.flame_fill, _outColor, 'เผาผลาญวันนี้'),
          const SizedBox(height: 16),
          // กินเข้า (left) · สุทธิ (center) · เผาผลาญ (right).
          // Stack so สุทธิ sits at the true horizontal centre of the card,
          // not the centre of the gap between the two (unequal) end stats.
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child:
                    _endStat('กินเข้า', inKcal, _inColor, CrossAxisAlignment.start),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child:
                    _endStat('เผาผลาญ', burned, _outColor, CrossAxisAlignment.end),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${net < 0 ? '-' : ''}${_fmt(net.abs())}',
                    style: numFont(const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: netColor,
                    )),
                  ),
                  const SizedBox(height: 2),
                  const Text('สุทธิ (kcal)',
                      style: TextStyle(fontSize: 10, color: _grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Single "vs" bar: กินเข้า (left) vs เผาผลาญ (right), proportional.
          // Both sides animate inward to meet, then a badge pops at the join.
          _VsBar(inKcal: inKcal, burned: burned),
          const SizedBox(height: 16),
          Container(height: 0.5, color: const Color(0xFFE5E5E5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _burnStat(_flameIcon(), _fmt(moveKcal), 'kcal'),
              ),
              _div(),
              Expanded(
                child: _burnStat(
                    const Icon(Icons.directions_walk,
                        size: 14, color: Color(0xFFE32616)),
                    _fmt(steps),
                    'ก้าว'),
              ),
              _div(),
              Expanded(
                child: _burnStat(
                    const Icon(CupertinoIcons.bolt_fill,
                        size: 14, color: Color(0xFF1D8B6B)),
                    '$exerciseMin',
                    'นาที'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _endStat(String label, int value, Color color, CrossAxisAlignment a) {
    return Column(
      crossAxisAlignment: a,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: _grey)),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _fmt(value),
              style: numFont(TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1,
                color: color,
              )),
            ),
            const SizedBox(width: 3),
            const Padding(
              padding: EdgeInsets.only(bottom: 1),
              child: Text('kcal', style: TextStyle(fontSize: 9, color: _muted)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _div() =>
      Container(width: 1, height: 30, color: const Color(0xFFE5E5E5));

  // Solid orange flame with a smaller white flame nested inside.
  Widget _flameIcon() => SizedBox(
        width: 14,
        height: 14,
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Icon(CupertinoIcons.flame_fill,
                size: 14, color: Color(0xFFFF6B3D)),
            Padding(
              padding: EdgeInsets.only(top: 2.5),
              child: Icon(CupertinoIcons.flame_fill,
                  size: 7, color: CupertinoColors.white),
            ),
          ],
        ),
      );

  Widget _burnStat(Widget icon, String value, String unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: numFont(const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: _ink))),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(unit, style: const TextStyle(fontSize: 9, color: _muted)),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Animated "vs" bar ────────────────────────────────────────────────────────

class _VsBar extends StatelessWidget {
  const _VsBar({required this.inKcal, required this.burned});
  final int inKcal;
  final int burned;

  static const _inColor = Color(0xFF1D8B6B);
  static const _outColor = Color(0xFFFF6B3D);
  static const _barH = 12.0;
  static const _badge = 26.0;

  @override
  Widget build(BuildContext context) {
    final inMore = inKcal >= burned;
    // in > out → มื้ออาหาร icon; out > in → มื้อล่าสุด icon.
    final icon = inMore ? Icons.restaurant : CupertinoIcons.flame_fill;
    final badgeColor = inMore ? _inColor : _outColor;
    final iconSize = inMore ? 12.0 : 13.0;

    return SizedBox(
      height: _badge,
      child: LayoutBuilder(
        builder: (context, c) {
          final totalW = c.maxWidth;
          const gap = 3.0;
          final usable = totalW - gap;
          final sum = (inKcal + burned) == 0 ? 1 : (inKcal + burned);
          final boundary = usable * (inKcal / sum);
          // Badge centred on the join (meeting point) of the two bars.
          final badgeLeft =
              (boundary + gap / 2 - _badge / 2).clamp(0.0, totalW - _badge);

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 950),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) {
              final inW = boundary * t;
              final outW = (usable - boundary) * t;
              final pop = Curves.easeOutBack
                  .transform(((t - 0.55) / 0.45).clamp(0.0, 1.0));
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // bar, vertically centred
                  Positioned(
                    left: 0,
                    right: 0,
                    top: (_badge - _barH) / 2,
                    height: _barH,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: inW,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              color: _inColor,
                              borderRadius:
                                  BorderRadius.horizontal(left: Radius.circular(100)),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: outW,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              color: _outColor,
                              borderRadius:
                                  BorderRadius.horizontal(right: Radius.circular(100)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // join badge
                  Positioned(
                    left: badgeLeft,
                    top: 0,
                    child: Transform.scale(
                      scale: pop,
                      child: Container(
                        width: _badge,
                        height: _badge,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badgeColor,
                          border: Border.all(
                              color: CupertinoColors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: badgeColor.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(icon,
                            size: iconSize, color: CupertinoColors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
