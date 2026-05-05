import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PromoBannerItem {
  final String imageAsset;
  final VoidCallback? onTap;

  const PromoBannerItem({required this.imageAsset, this.onTap});
}

class HomePromoBanner extends StatefulWidget {
  final List<PromoBannerItem> items;
  final Duration autoScrollInterval;

  const HomePromoBanner({
    super.key,
    required this.items,
    this.autoScrollInterval = const Duration(seconds: 4),
  });

  @override
  State<HomePromoBanner> createState() => _HomePromoBannerState();
}

class _HomePromoBannerState extends State<HomePromoBanner> {
  static const double _aspectRatio = 5 / 2; // 358:143 mid-banner
  static const double _horizontalMargin = 16;
  static const double _radius = 20;

  late final PageController _ctrl;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: 0, viewportFraction: 1);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (widget.items.length <= 1) return;
    _timer = Timer.periodic(widget.autoScrollInterval, (_) {
      if (!mounted || !_ctrl.hasClients) return;
      final next = (_index + 1) % widget.items.length;
      _ctrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: _aspectRatio,
            child: PageView.builder(
              controller: _ctrl,
              itemCount: widget.items.length,
              clipBehavior: Clip.none,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalMargin,
                  vertical: 4,
                ),
                child: _BannerCard(
                  item: widget.items[i],
                  radius: _radius,
                ),
              ),
            ),
          ),
          if (widget.items.length > 1) ...[
            const SizedBox(height: 12),
            _Indicators(count: widget.items.length, current: _index),
          ],
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final PromoBannerItem item;
  final double radius;

  const _BannerCard({required this.item, required this.radius});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Image.asset(
          item.imageAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

class _Indicators extends StatelessWidget {
  final int count;
  final int current;

  const _Indicators({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == current
                  ? AppColors.primary600
                  : AppColors.borderDefault,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
      ],
    );
  }
}
