import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'glass_card.dart';

class MetricCard extends StatefulWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    this.chart,
    this.chartHeight,
    this.bottom,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.showChevron = true,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final Widget? chart;
  final double? chartHeight;
  final Widget? bottom;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool showChevron;

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final primary = isDark ? AppColors.labelDark : AppColors.label;
    final secondary =
        isDark ? AppColors.secondaryLabelDark : AppColors.secondaryLabel;
    final chevron =
        isDark ? AppColors.tertiaryLabelDark : AppColors.tertiaryLabel;
    final chartWidget = widget.chart;
    final bottomWidget = widget.bottom;
    final hasValue = widget.value.isNotEmpty || widget.unit.isNotEmpty;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: widget.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.iconColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(widget.icon,
                          size: 13, color: CupertinoColors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: AppTypography.subheadline(primary)
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.showChevron)
                      Icon(CupertinoIcons.chevron_right,
                          size: 12, color: chevron),
                  ],
                ),
                if (hasValue) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(widget.value,
                          style: AppTypography.title1(primary)),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(widget.unit,
                            style: AppTypography.caption2(secondary)),
                      ),
                    ],
                  ),
                ],
                if (chartWidget != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                      height: widget.chartHeight ?? 56, child: chartWidget),
                ],
                if (bottomWidget != null) ...[
                  const SizedBox(height: 8),
                  bottomWidget,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
