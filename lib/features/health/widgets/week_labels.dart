import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class WeekLabels extends StatelessWidget {
  const WeekLabels({super.key, this.labels});

  final List<String>? labels;

  static const List<String> _thShort = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];

  static List<String> fromDates(List<DateTime> dates) =>
      [for (final d in dates) _thShort[d.weekday % 7]];

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final color =
        isDark ? AppColors.tertiaryLabelDark : AppColors.tertiaryLabel;
    final days = labels ?? _thShort;
    return Row(
      children: [
        for (final d in days)
          Expanded(
            child: Center(
              child: Text(d, style: AppTypography.caption2(color)),
            ),
          ),
      ],
    );
  }
}
