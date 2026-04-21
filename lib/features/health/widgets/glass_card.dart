import 'dart:ui';
import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark =
        CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final bg = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.65)
        : AppColors.surface.withValues(alpha: 0.75);
    final borderColor = isDark
        ? const Color(0x33FFFFFF)
        : const Color(0x1A000000);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
