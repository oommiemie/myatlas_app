import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

import 'press_effect.dart';

/// iOS-26-style Liquid Glass circular icon button.
/// Uses a multi-layer composition: backdrop blur + saturation boost,
/// translucent tint (white or colored), top-left specular highlight,
/// and a gradient glass rim.
class LiquidGlassButton extends StatelessWidget {
  const LiquidGlassButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = const Color(0xFF1A1A1A),
    this.tint,
    this.size = 40,
    this.iconSize,
    this.haptic = HapticKind.selection,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color iconColor;

  /// Tint color. When null the button is pure glass (translucent white).
  /// When set, the button becomes colored glass (primary/accent action).
  final Color? tint;
  final double size;
  final double? iconSize;
  final HapticKind haptic;

  @override
  Widget build(BuildContext context) {
    final hasTint = tint != null;
    final resolvedIconSize = iconSize ?? size * 0.45;
    return PressEffect(
      onTap: onTap,
      haptic: haptic,
      rippleShape: BoxShape.circle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (tint ?? CupertinoColors.black)
                  .withValues(alpha: hasTint ? 0.35 : 0.12),
              blurRadius: hasTint ? 18 : 24,
              offset: Offset(0, hasTint ? 8 : 6),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Frosted backdrop
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.compose(
                    outer: const ColorFilter.matrix(_glassSaturateMatrix),
                    inner: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              // 2. Base tint
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: hasTint
                            ? [
                                tint!.withValues(alpha: 0.92),
                                tint!.withValues(alpha: 1.0),
                              ]
                            : [
                                CupertinoColors.white.withValues(alpha: 0.75),
                                CupertinoColors.white.withValues(alpha: 0.55),
                              ],
                      ),
                    ),
                  ),
                ),
              ),
              // 3. Specular highlight top-left
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.55, -0.95),
                        radius: 1.3,
                        colors: [
                          CupertinoColors.white
                              .withValues(alpha: hasTint ? 0.45 : 0.5),
                          CupertinoColors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 4. Glass rim — bright top-left → faint bottom-right
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _CircleRimPainter()),
                ),
              ),
              // 5. Icon
              Icon(icon, color: iconColor, size: resolvedIconSize),
            ],
          ),
        ),
      ),
    );
  }
}

const List<double> _glassSaturateMatrix = <double>[
  1.4722, -0.4290, -0.0432, 0, 0,
  -0.1278, 1.1710, -0.0432, 0, 0,
  -0.1278, -0.4290, 1.5568, 0, 0,
  0, 0, 0, 1, 0,
];

class _CircleRimPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          CupertinoColors.white.withValues(alpha: 0.85),
          CupertinoColors.white.withValues(alpha: 0.2),
        ],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _CircleRimPainter old) => false;
}
