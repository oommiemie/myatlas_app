import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// Pinned screen header that keeps the large title and the action button on
/// the SAME row.
///
/// `CupertinoSliverNavigationBar` stacks them — the action sits in the small
/// bar and the large title drops onto its own row underneath. This keeps the
/// iOS collapse behaviour (title shrinks, bar blurs on scroll) but lays the
/// two out side by side the whole way through.
class LargeTitleHeader extends StatelessWidget {
  const LargeTitleHeader({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.action,
  });

  final String title;
  final Color backgroundColor;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _LargeTitleDelegate(
        title: title,
        backgroundColor: backgroundColor,
        action: action,
        topInset: MediaQuery.paddingOf(context).top,
      ),
    );
  }
}

class _LargeTitleDelegate extends SliverPersistentHeaderDelegate {
  _LargeTitleDelegate({
    required this.title,
    required this.backgroundColor,
    required this.action,
    required this.topInset,
  });

  final String title;
  final Color backgroundColor;
  final Widget? action;
  final double topInset;

  // Row height at rest and once collapsed. The action button is 36pt; the
  // extra room keeps its shadow inside the clip instead of shearing it off.
  static const double _expandedRow = 60;
  static const double _collapsedRow = 52;

  static const double _titleMax = 32;
  static const double _titleMin = 19;

  @override
  double get maxExtent => topInset + _expandedRow;

  @override
  double get minExtent => topInset + _collapsedRow;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final t = range == 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    final fontSize = lerpDouble(_titleMax, _titleMin, t)!;
    // Blur and background only fade in once the header starts collapsing, so
    // it sits flat on the page while at rest.
    final blur = 20 * t;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          color: backgroundColor.withValues(alpha: 0.85 * t),
          padding: EdgeInsets.only(top: topInset, left: 16, right: 16),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF1A1A1A),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    fontVariations: const [FontVariation('wght', 700)],
                    letterSpacing: -0.4,
                    height: 1.15,
                  ),
                ),
              ),
              if (action != null) ...[const SizedBox(width: 12), action!],
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_LargeTitleDelegate old) =>
      old.title != title ||
      old.backgroundColor != backgroundColor ||
      old.topInset != topInset ||
      old.action != action;
}
