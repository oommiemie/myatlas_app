import 'package:flutter/material.dart';

/// A single drifting cloud config.
class _Cloud {
  const _Cloud({
    required this.asset,
    required this.dy,
    required this.width,
    required this.phase,
    required this.speed,
    required this.opacity,
  });

  final String asset;
  final double dy; // vertical offset below the status bar
  final double width;
  final double phase; // 0..1 starting position along the loop
  final int speed; // integer multiplier (keeps the loop seamless)
  final double opacity;
}

/// Clouds drifting across the header — seamless loop (no stutter): one repeating
/// controller, each cloud's x is `((value*speed + phase) % 1)` mapped across the
/// width + cloud width, so it wraps off-screen and stays continuous at the
/// controller's 1→0 boundary.
class HeaderClouds extends StatefulWidget {
  const HeaderClouds({super.key});

  @override
  State<HeaderClouds> createState() => _HeaderCloudsState();
}

class _HeaderCloudsState extends State<HeaderClouds>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  )..repeat();

  // Same speed for all + evenly spread phases → constant spacing, never bunches.
  // Kept within the sky band (top) and not too many.
  static const _clouds = [
    _Cloud(asset: 'assets/sky1.webp', dy: 6, width: 116, phase: 0.00, speed: 1, opacity: 0.90),
    _Cloud(asset: 'assets/sky3.webp', dy: 40, width: 54, phase: 0.25, speed: 1, opacity: 0.82),
    _Cloud(asset: 'assets/sky2.webp', dy: 20, width: 84, phase: 0.50, speed: 1, opacity: 0.80),
    _Cloud(asset: 'assets/sky4.webp', dy: 48, width: 64, phase: 0.75, speed: 1, opacity: 0.75),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return IgnorePointer(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                return Stack(
                  children: [
                    for (final cl in _clouds)
                      Positioned(
                        top: top + cl.dy,
                        left: -cl.width +
                            ((_ctrl.value * cl.speed + cl.phase) % 1.0) *
                                (w + cl.width),
                        child: Opacity(
                          opacity: cl.opacity,
                          child: Image.asset(
                            cl.asset,
                            width: cl.width,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
