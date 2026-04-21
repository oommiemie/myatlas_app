import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'activity_ring.dart';
import 'glass_card.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
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

  @override
  Widget build(BuildContext context) {
    final isDark =
        CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final primary = isDark ? AppColors.labelDark : AppColors.label;
    final secondary =
        isDark ? AppColors.secondaryLabelDark : AppColors.secondaryLabel;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ActivityRing(
                  progress: move / moveGoal,
                  color: AppColors.health,
                  size: 96,
                  strokeWidth: 11,
                ),
                ActivityRing(
                  progress: exercise / exerciseGoal,
                  color: AppColors.nutrition,
                  size: 70,
                  strokeWidth: 10,
                ),
                ActivityRing(
                  progress: stand / standGoal,
                  color: AppColors.mindfulness,
                  size: 46,
                  strokeWidth: 9,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('กิจกรรมวันนี้',
                    style: AppTypography.headline(primary)),
                const SizedBox(height: 8),
                _ringRow('เคลื่อนไหว', '$move/$moveGoal kcal',
                    AppColors.health, secondary, primary),
                const SizedBox(height: 6),
                _ringRow('ออกกำลังกาย',
                    '$exercise/$exerciseGoal นาที',
                    AppColors.nutrition, secondary, primary),
                const SizedBox(height: 6),
                _ringRow('ยืน', '$stand/$standGoal ชม.',
                    AppColors.mindfulness, secondary, primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ringRow(
    String label,
    String value,
    Color dot,
    Color secondary,
    Color primary,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: AppTypography.subheadline(secondary)),
        ),
        Text(value, style: AppTypography.subheadline(primary)),
      ],
    );
  }
}
