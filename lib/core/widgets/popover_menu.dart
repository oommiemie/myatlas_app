import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class PopoverMenuAction {
  const PopoverMenuAction({
    required this.label,
    required this.icon,
    this.destructive = false,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final bool destructive;
  final VoidCallback? onTap;
}

/// Show a contextual popover menu that emerges from the widget pointed to by
/// [anchorKey] — iOS-style frosted glass card with scale+fade from the anchor.
Future<void> showPopoverMenu({
  required BuildContext context,
  required GlobalKey anchorKey,
  required List<PopoverMenuAction> actions,
  double menuWidth = 260,
}) async {
  final box = anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return;
  final topLeft = box.localToGlobal(Offset.zero);
  final anchorRect = topLeft & box.size;

  HapticFeedback.selectionClick();

  await Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.05),
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, anim, sec) => _PopoverMenuOverlay(
        anchorRect: anchorRect,
        menuWidth: menuWidth,
        actions: actions,
        animation: anim,
      ),
    ),
  );
}

class _PopoverMenuOverlay extends StatelessWidget {
  const _PopoverMenuOverlay({
    required this.anchorRect,
    required this.menuWidth,
    required this.actions,
    required this.animation,
  });
  final Rect anchorRect;
  final double menuWidth;
  final List<PopoverMenuAction> actions;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const margin = 16.0;
    const gap = 10.0;
    final menuHeight = actions.length * 48.0;

    // Prefer below; flip above if no space.
    final belowSpace = size.height - anchorRect.bottom;
    final showBelow = belowSpace > menuHeight + 40;

    final menuTop = showBelow
        ? anchorRect.bottom + gap
        : anchorRect.top - gap - menuHeight;

    // Horizontal: align menu center to anchor center, clamp to screen.
    final anchorCenterX = anchorRect.center.dx;
    double menuLeft = anchorCenterX - menuWidth / 2;
    if (menuLeft < margin) menuLeft = margin;
    if (menuLeft + menuWidth > size.width - margin) {
      menuLeft = size.width - margin - menuWidth;
    }

    // Scale origin expressed as Alignment within the menu box,
    // pointed at the anchor's center.
    final relX = ((anchorCenterX - menuLeft) / menuWidth) * 2 - 1;
    final origin = Alignment(relX.clamp(-1.0, 1.0), showBelow ? -1.0 : 1.0);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Color(0x00000000)),
          ),
        ),
        Positioned(
          left: menuLeft,
          top: menuTop,
          width: menuWidth,
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, child) {
              final t = Curves.easeOutCubic.transform(animation.value);
              return Opacity(
                opacity: t,
                child: Transform.scale(
                  scale: 0.7 + t * 0.3,
                  alignment: origin,
                  child: child,
                ),
              );
            },
            child: _MenuCard(
              actions: actions,
              onItemTap: (a) async {
                await Navigator.of(context).maybePop();
                a.onTap?.call();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.actions, required this.onItemTap});
  final List<PopoverMenuAction> actions;
  final void Function(PopoverMenuAction action) onItemTap;

  @override
  Widget build(BuildContext context) {
    const radius = 26.0;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.28),
            blurRadius: 64,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            // 1. Heavy blur + strong saturation boost (Apple vibrancy)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.compose(
                  outer: const ColorFilter.matrix(_liquidGlassMatrix),
                  inner: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                ),
                child: const SizedBox.expand(),
              ),
            ),
            // 2. Light frosted tint — same feel as the iOS nav bar
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF4F8F5).withValues(alpha: 0.78),
                        const Color(0xFFE9F2F0).withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 3. Gentle top-left specular
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.7, -1.2),
                      radius: 1.5,
                      colors: [
                        CupertinoColors.white.withValues(alpha: 0.2),
                        CupertinoColors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 5. Inner rim glow (luminous edge — the hallmark of liquid glass)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _LiquidRimPainter(radius: radius),
                ),
              ),
            ),
            // 6. Thin bright top specular line
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 1,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.white.withValues(alpha: 0),
                        CupertinoColors.white.withValues(alpha: 0.5),
                        CupertinoColors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 7. Content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    _MenuItem(
                      action: actions[i],
                      onTap: () => onItemTap(actions[i]),
                    ),
                    if (i != actions.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 0.33,
                          color:
                              CupertinoColors.black.withValues(alpha: 0.10),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Saturation 1.6 matrix (Rec.709 luminance weights) — boosts color richness
// of content behind the glass, like Apple's vibrancy layer.
const List<double> _liquidGlassMatrix = <double>[
  1.4722, -0.4290, -0.0432, 0, 0,
  -0.1278, 1.1710, -0.0432, 0, 0,
  -0.1278, -0.4290, 1.5568, 0, 0,
  0, 0, 0, 1, 0,
];

/// Paints an inner luminous rim around the RRect — brighter at the top-left,
/// fading to a thin dark seam at the bottom-right. Gives the card a glass
/// thickness and refracted-edge look.
class _LiquidRimPainter extends CustomPainter {
  _LiquidRimPainter({required this.radius});
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Outer rim — bright top-left → dim bottom-right
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          CupertinoColors.white.withValues(alpha: 0.85),
          CupertinoColors.white.withValues(alpha: 0.25),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, rim);
  }

  @override
  bool shouldRepaint(covariant _LiquidRimPainter old) =>
      old.radius != radius;
}

class _MenuItem extends StatefulWidget {
  const _MenuItem({required this.action, required this.onTap});
  final PopoverMenuAction action;
  final VoidCallback onTap;

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final destructive = widget.action.destructive;
    final fg = destructive
        ? const Color(0xFFFF3B30)
        : const Color(0xFF1A1A1A);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 54,
        decoration: BoxDecoration(
          color: _pressed
              ? CupertinoColors.black.withValues(alpha: 0.06)
              : const Color(0x00000000),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Icon(widget.action.icon, size: 22, color: fg),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.action.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
