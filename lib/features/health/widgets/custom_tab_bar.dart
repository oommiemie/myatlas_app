import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TabItem {
  const TabItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.activeColor = AppColors.brandPrimary,
  });

  final List<TabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  static const _indicatorCurve = Cubic(0.34, 1.36, 0.64, 1.0);
  static const _indicatorDuration = Duration(milliseconds: 460);

  int _pressedIndex = -1;

  void _handleTap(int i) {
    if (i == widget.currentIndex) return;
    HapticFeedback.selectionClick();
    widget.onTap(i);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final inactive =
        isDark ? AppColors.secondaryLabelDark : AppColors.textTertiary;
    final active = widget.activeColor;
    final indicatorFill = isDark
        ? CupertinoColors.white.withValues(alpha: 0.14)
        : const Color(0xFFEDEDED);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: _GlassPill(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slot = constraints.maxWidth / widget.items.length;
              const gap = 4.0;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: _indicatorDuration,
                    curve: _indicatorCurve,
                    left: slot * widget.currentIndex + gap / 2,
                    top: 0,
                    bottom: 0,
                    width: slot - gap,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: indicatorFill,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (int i = 0; i < widget.items.length; i++)
                        Expanded(
                          child: _TabButton(
                            item: widget.items[i],
                            selected: i == widget.currentIndex,
                            pressed: i == _pressedIndex,
                            activeColor: active,
                            inactiveColor: inactive,
                            onTapDown: (_) =>
                                setState(() => _pressedIndex = i),
                            onTapUp: (_) =>
                                setState(() => _pressedIndex = -1),
                            onTapCancel: () =>
                                setState(() => _pressedIndex = -1),
                            onTap: () => _handleTap(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final tint = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.55)
        : CupertinoColors.white.withValues(alpha: 0.55);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.04),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.10),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: CustomPaint(
            painter: _LiquidGlassPainter(isDark: isDark),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassPainter extends CustomPainter {
  _LiquidGlassPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final topHighlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          CupertinoColors.white.withValues(alpha: isDark ? 0.14 : 0.60),
          CupertinoColors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(rrect, topHighlight);

    final bottomShade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          CupertinoColors.black.withValues(alpha: 0.0),
          CupertinoColors.black.withValues(alpha: isDark ? 0.16 : 0.06),
        ],
        stops: const [0.65, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(rrect, bottomShade);

    final outerRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = CupertinoColors.white.withValues(alpha: isDark ? 0.22 : 0.95);
    canvas.drawRRect(rrect.deflate(0.25), outerRim);

    final innerRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          CupertinoColors.white.withValues(alpha: isDark ? 0.12 : 0.55),
          CupertinoColors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(rrect.deflate(1.2), innerRim);
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassPainter old) =>
      old.isDark != isDark;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.pressed,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  final TabItem item;
  final bool selected;
  final bool pressed;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;
  final GestureTapDownCallback onTapDown;
  final GestureTapUpCallback onTapUp;
  final GestureTapCancelCallback onTapCancel;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 11),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: selected ? 1.05 : 1.0),
                duration: const Duration(milliseconds: 320),
                curve: const Cubic(0.34, 1.36, 0.64, 1.0),
                builder: (_, scale, child) => Transform.scale(
                  scale: scale,
                  child: child,
                ),
                child: Icon(item.icon, size: 22, color: color),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: AppTypography.caption2(color).copyWith(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: selected ? -0.1 : 0,
                  height: 1.2,
                ),
                child: Text(item.label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
