import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TipCard extends StatelessWidget {
  const TipCard({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  static const _violet = Color(0xFF7C3AED);
  static const _textTertiary = Color(0xFF6D756E);
  static const _textPrimary = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final bodyColor = isDark ? AppColors.labelDark : _textPrimary;

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
      padding: const EdgeInsets.all(16),
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
                  color: _violet,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.sparkles,
                  size: 13,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.caption1(_textTertiary)
                      .copyWith(fontSize: 12, letterSpacing: 0.275),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: AppTypography.footnote(bodyColor).copyWith(
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0.14,
            ),
          ),
        ],
      ),
    );
  }
}
