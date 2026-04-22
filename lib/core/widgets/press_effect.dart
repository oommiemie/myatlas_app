import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Wraps [child] with a scale+dim press effect, haptic, click sound,
/// and an expanding water-droplet ripple emanating from the tap point.
class PressEffect extends StatefulWidget {
  const PressEffect({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.94,
    this.dim = 0.88,
    this.haptic = HapticKind.light,
    this.playClick = false,
    this.behavior = HitTestBehavior.opaque,
    this.ripple = true,
    this.rippleColor,
    this.rippleShape = BoxShape.rectangle,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final double dim;
  final HapticKind haptic;
  final bool playClick;
  final HitTestBehavior behavior;
  final bool ripple;
  final Color? rippleColor;
  final BoxShape rippleShape;
  final BorderRadius? borderRadius;

  @override
  State<PressEffect> createState() => _PressEffectState();
}

enum HapticKind { none, selection, light, medium, heavy }

class _PressEffectState extends State<PressEffect>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  final List<_Ripple> _ripples = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1, end: widget.scale).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 1, end: widget.dim).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    for (final r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  void _fireHaptic() {
    switch (widget.haptic) {
      case HapticKind.none:
        break;
      case HapticKind.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticKind.light:
        HapticFeedback.lightImpact();
        break;
      case HapticKind.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticKind.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  void _spawnRipple(Offset localPosition, Size size) {
    if (!widget.ripple) return;
    final dx = localPosition.dx.clamp(0.0, size.width);
    final dy = localPosition.dy.clamp(0.0, size.height);
    final farthest = [
      Offset(dx, dy).distance,
      Offset(size.width - dx, dy).distance,
      Offset(dx, size.height - dy).distance,
      Offset(size.width - dx, size.height - dy).distance,
    ].reduce((a, b) => a > b ? a : b);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    final ripple = _Ripple(
      center: Offset(dx, dy),
      maxRadius: farthest + 4,
      controller: controller,
    );
    _ripples.add(ripple);
    controller.addListener(() {
      if (mounted) setState(() {});
    });
    controller.forward().whenComplete(() {
      _ripples.remove(ripple);
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.rippleColor ??
        CupertinoColors.white.withValues(alpha: 0.28);
    final radius = widget.rippleShape == BoxShape.circle
        ? null
        : (widget.borderRadius ?? BorderRadius.zero);

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (d) {
        _ctrl.forward();
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          _spawnRipple(d.localPosition, box.size);
        }
      },
      onTapUp: (_) {
        _ctrl.reverse();
      },
      onTapCancel: () {
        _ctrl.reverse();
      },
      onTap: widget.onTap == null
          ? null
          : () {
              _fireHaptic();
              if (widget.playClick) SystemSound.play(SystemSoundType.click);
              widget.onTap!();
            },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        ),
        child: Stack(
          children: [
            widget.child,
            if (widget.ripple)
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipPath(
                    clipper: _ShapeClipper(
                      shape: widget.rippleShape,
                      borderRadius: radius,
                    ),
                    child: CustomPaint(
                      painter: _RipplePainter(
                        ripples: _ripples,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Ripple {
  _Ripple({
    required this.center,
    required this.maxRadius,
    required this.controller,
  });
  final Offset center;
  final double maxRadius;
  final AnimationController controller;
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({required this.ripples, required this.color});
  final List<_Ripple> ripples;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in ripples) {
      final t = Curves.easeOut.transform(r.controller.value);
      final radius = r.maxRadius * t;
      final alpha = (1 - r.controller.value).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = color.withValues(alpha: color.a * alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(r.center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) => true;
}

class _ShapeClipper extends CustomClipper<Path> {
  _ShapeClipper({required this.shape, required this.borderRadius});
  final BoxShape shape;
  final BorderRadius? borderRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    if (shape == BoxShape.circle) {
      path.addOval(Offset.zero & size);
    } else if (borderRadius != null && borderRadius != BorderRadius.zero) {
      path.addRRect(borderRadius!.toRRect(Offset.zero & size));
    } else {
      path.addRect(Offset.zero & size);
    }
    return path;
  }

  @override
  bool shouldReclip(covariant _ShapeClipper old) =>
      old.shape != shape || old.borderRadius != borderRadius;
}
