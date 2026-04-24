import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../core/widgets/liquid_glass_button.dart';

/// Soft mint→background vertical gradient that sits behind every health
/// detail screen. Matches the Profile screen visual — no vital-specific
/// colour. Place it inside a `Positioned(top: 0, left: 0, right: 0, height:
/// 180)` inside the screen's outer `Stack`.
class DetailHeaderBackground extends StatelessWidget {
  const DetailHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE4F5F0), Color(0xFFF4F8F5)],
          stops: [0.0, 0.7],
        ),
      ),
    );
  }
}

/// Pinned top bar used across detail screens under the Health tab. Title
/// and icons are always rendered dark — the soft mint gradient behind the
/// bar provides enough contrast, so there is no white→dark fade. As the
/// user scrolls a light blurred backdrop fades in.
///
/// Wrap the screen's scrollable with a `NotificationListener<ScrollNotification>`
/// that pushes `metrics.pixels` into a `ValueNotifier<double>` and feed that
/// offset in via [scrollOffset].
class HealthDetailAppBar extends StatelessWidget {
  const HealthDetailAppBar({
    super.key,
    required this.title,
    required this.scrollOffset,
    required this.onBack,
    this.action,
  });

  final String title;
  final double scrollOffset;
  final VoidCallback onBack;
  final Widget? action;

  static const Color _foreground = Color(0xFF1A1A1A);
  static const double _fadeDistance = 140.0;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final progress = (scrollOffset / _fadeDistance).clamp(0.0, 1.0);
    final barHeight = top + 6 + 44 + 6;

    return Stack(
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22 * progress,
              sigmaY: 22 * progress,
            ),
            child: Container(
              height: barHeight,
              color: const Color(0xFFF4F8F5)
                  .withValues(alpha: 0.80 * progress),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
            opacity: progress,
            child: Container(
              height: 0.5,
              color: CupertinoColors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: top + 6, left: 14, right: 14),
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: LiquidGlassButton(
                    icon: CupertinoIcons.chevron_back,
                    onTap: onBack,
                    size: 40,
                    iconSize: 18,
                  ),
                ),
                if (action != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: action!,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static double contentOffset(BuildContext context) {
    return MediaQuery.paddingOf(context).top + 6 + 44 + 6;
  }

  static const double safeAreaContentHeight = 56;
}
