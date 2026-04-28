import 'package:flutter/cupertino.dart';

/// Centers and width-clamps [child] when running on devices wider than a
/// phone (tablet, desktop, web). On phones it passes through unchanged.
///
/// The space around the constrained content (the "bezel") is filled with
/// [bezelColor] so the page never looks awkwardly stretched.
class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({
    super.key,
    required this.child,
    this.maxContentWidth = 520,
    this.phoneBreakpoint = 600,
    this.bezelColor = const Color(0xFFEAECEC),
  });

  final Widget child;
  final double maxContentWidth;
  final double phoneBreakpoint;
  final Color bezelColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= phoneBreakpoint) return child;
        return ColoredBox(
          color: bezelColor,
          child: Center(
            child: SizedBox(
              width: maxContentWidth,
              child: ClipRect(child: child),
            ),
          ),
        );
      },
    );
  }
}
