import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'mini_charts.dart';
import 'week_labels.dart';

class ActiveEnergyCard extends StatelessWidget {
  const ActiveEnergyCard({
    super.key,
    required this.kcal,
    required this.weekly,
    this.dates,
    this.highlightIndex,
    this.onTouch,
  });

  final int kcal;
  final List<double> weekly;
  final List<DateTime>? dates;
  final int? highlightIndex;
  final ValueChanged<int?>? onTouch;

  static const _ruby = Color(0xFFE32616);
  static const _textTertiary = Color(0xFF6D756E);
  static const _neutral500 = Color(0xFF737373);

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final primary = isDark ? AppColors.labelDark : CupertinoColors.black;
    final labels = dates != null
        ? WeekLabels.fromDates(dates!)
        : WeekLabels.fromDates(_defaultDates());
    return Container(
      height: 190,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Bars + weekday labels on the right side
            Positioned(
              right: 12,
              top: 16,
              bottom: 10,
              width: 250,
              child: Column(
                children: [
                  Expanded(
                    child: MiniBarChart(
                      values: weekly,
                      dates: dates,
                      color: _ruby,
                      highlightIndex: highlightIndex,
                      highlightColor: const Color(0xFFBFBFC2),
                      dimAlpha: 1.0,
                      useDimGradient: true,
                      dimGradient: const [
                        Color(0xFFDADADD),
                        Color(0x33E8E8EA),
                      ],
                      barWidth: 10,
                      unit: ' kcal',
                      onTouch: onTouch,
                    ),
                  ),
                  const SizedBox(height: 6),
                  WeekLabels(labels: labels),
                ],
              ),
            ),
            // Header (icon + label)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: _ruby,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.flame,
                      size: 13,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active Energy',
                    style: AppTypography.caption1(_textTertiary)
                        .copyWith(fontSize: 12, letterSpacing: 0.275),
                  ),
                ],
              ),
            ),
            // Full-width red separator line at y=118 (behind the "114 kcl")
            Positioned(
              left: 16,
              right: 16,
              top: 118,
              child: Container(height: 1.5, color: _ruby),
            ),
            // Label + value on the bottom-left
            Positioned(
              left: 16,
              top: 92,
              child: Text(
                'Active Kilocalories',
                style: AppTypography.caption2(_neutral500)
                    .copyWith(fontSize: 10),
              ),
            ),
            Positioned(
              left: 16,
              top: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$kcal',
                    style: AppTypography.title2(primary).copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.6,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'kcl',
                      style: AppTypography.caption2(_neutral500)
                          .copyWith(fontSize: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _defaultDates() {
    final today = DateTime.now();
    final sunday =
        DateTime(today.year, today.month, today.day - (today.weekday % 7));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }
}
