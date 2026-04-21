import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'activity_ring.dart';

class MiniActivityCard extends StatelessWidget {
  const MiniActivityCard({
    super.key,
    required this.move,
    required this.moveGoal,
    required this.exercise,
    required this.exerciseGoal,
    required this.stand,
    required this.standGoal,
  });

  final int move;
  final int moveGoal;
  final int exercise;
  final int exerciseGoal;
  final int stand;
  final int standGoal;

  static const _indigo = Color(0xFF4F46E5);
  static const _textTertiary = Color(0xFF6D756E);
  static const _neutral500 = Color(0xFF737373);
  static const _moveLabel = Color(0xFFBE123C);
  static const _exerciseLabel = Color(0xFF1D4ED8);
  static const _standLabel = Color(0xFF4D7C0F);

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final primary = isDark ? AppColors.labelDark : CupertinoColors.black;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.65)
            : AppColors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0x33FFFFFF)
              : const Color(0x1A000000),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: _indigo,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.adjust,
                  size: 14,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Activity',
                style: AppTypography.caption1(_textTertiary)
                    .copyWith(fontSize: 12, letterSpacing: 0.275),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ActivityRing(
                      progress: move / moveGoal,
                      color: AppColors.health,
                      gradient: const [
                        Color(0xFFFF3864),
                        Color(0xFFFF7E9E),
                      ],
                      size: 84,
                      strokeWidth: 9,
                    ),
                    ActivityRing(
                      progress: exercise / exerciseGoal,
                      color: AppColors.nutrition,
                      gradient: const [
                        Color(0xFF17C964),
                        Color(0xFFB5F05C),
                      ],
                      size: 60,
                      strokeWidth: 8,
                    ),
                    ActivityRing(
                      progress: stand / standGoal,
                      color: AppColors.mindfulness,
                      gradient: const [
                        Color(0xFF2DB5E1),
                        Color(0xFF6FE0F5),
                      ],
                      size: 36,
                      strokeWidth: 7,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Stat(
                      label: 'Move',
                      labelColor: _moveLabel,
                      value: '$move',
                      unit: 'Kcl',
                      valueColor: primary,
                      unitColor: _neutral500,
                    ),
                    const SizedBox(height: 10),
                    _Stat(
                      label: 'Exerise',
                      labelColor: _exerciseLabel,
                      value: '$exercise',
                      unit: 'min',
                      valueColor: primary,
                      unitColor: _neutral500,
                    ),
                    const SizedBox(height: 10),
                    _Stat(
                      label: 'Stand',
                      labelColor: _standLabel,
                      value: _formatHours(stand, standGoal),
                      unit: 'hr',
                      valueColor: primary,
                      unitColor: _neutral500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatHours(int stand, int standGoal) {
    if (standGoal == 0) return '0';
    final fraction = stand / standGoal;
    return fraction.toStringAsFixed(1);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.labelColor,
    required this.value,
    required this.unit,
    required this.valueColor,
    required this.unitColor,
  });

  final String label;
  final Color labelColor;
  final String value;
  final String unit;
  final Color valueColor;
  final Color unitColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.caption2(labelColor).copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTypography.caption1(valueColor).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 1.5),
              child: Text(
                unit,
                style: AppTypography.caption2(unitColor).copyWith(fontSize: 9),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
