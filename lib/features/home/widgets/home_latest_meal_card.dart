import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

const Color _macroProteinColor = Color(0xFFE62E05);
const Color _macroCarbColor = Color(0xFFA88B5B);
const Color _macroFatColor = Color(0xFFEAAA08);
const Color _macroSodiumColor = Color(0xFF0086C9);

class _RingSegment {
  final double value;
  final Color color;

  const _RingSegment({required this.value, required this.color});
}

class _MacroRingPainter extends CustomPainter {
  final List<_RingSegment> segments;
  final double strokeWidth;
  final double gapAngle;

  _MacroRingPainter({
    required this.segments,
    required this.strokeWidth,
    this.gapAngle = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;
    final totalGap = gapAngle * segments.length;
    final availableSweep = 2 * math.pi - totalGap;
    double start = -math.pi / 2 + gapAngle / 2;
    for (final seg in segments) {
      final sweep = (seg.value / total) * availableSweep;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _MacroRingPainter oldDelegate) {
    return segments != oldDelegate.segments ||
        strokeWidth != oldDelegate.strokeWidth ||
        gapAngle != oldDelegate.gapAngle;
  }
}

class HomeLatestMealCard extends StatelessWidget {
  const HomeLatestMealCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgPrimary,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'อาหารมื้อล่าสุด',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Color(0xFF1D8B6B),
                  Color(0xFF093327),
                ],
                stops: [0.16, 1.0],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderDefault, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MealRow(),
                const SizedBox(height: 12),
                _MacroRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFFD4B886),
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE9EFEA),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.restaurant,
                size: 20,
                color: Color(0xFF3E453F),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'อาหารที่ทาน',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'กระเพราไก่ไข่ดาว',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xE6FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          _CalorieRing(),
        ],
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(
              painter: _MacroRingPainter(
                segments: const [
                  _RingSegment(value: 25, color: _macroProteinColor),
                  _RingSegment(value: 45, color: _macroCarbColor),
                  _RingSegment(value: 30, color: _macroFatColor),
                  _RingSegment(value: 60, color: _macroSodiumColor),
                ],
                strokeWidth: 4,
                gapAngle: 0.08,
              ),
            ),
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '500',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              Text(
                'kcal',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: _MacroItem(
              label: 'โปรตีน',
              value: '32',
              unit: 'g',
              pct: '25%',
              pctColor: _macroProteinColor,
            ),
          ),
          _MacroDivider(),
          const Expanded(
            child: _MacroItem(
              label: 'คาร์โบไฮเดต',
              value: '55',
              unit: 'g',
              pct: '45%',
              pctColor: _macroCarbColor,
            ),
          ),
          _MacroDivider(),
          const Expanded(
            child: _MacroItem(
              label: 'ไขมัน',
              value: '22',
              unit: 'g',
              pct: '30%',
              pctColor: _macroFatColor,
            ),
          ),
          _MacroDivider(),
          const Expanded(
            child: _MacroItem(
              label: 'โซเดียม',
              value: '1,200',
              unit: 'mg',
              pct: '60%',
              pctColor: _macroSodiumColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.borderDefault,
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String pct;
  final Color pctColor;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.pct,
    required this.pctColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: pctColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pct,
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(text: ' ', style: TextStyle(fontSize: 10)),
              TextSpan(
                text: unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
