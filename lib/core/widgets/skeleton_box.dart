import 'package:flutter/material.dart';

/// Shared shimmer skeleton placeholder. Pass an [AnimationController] that's
/// already repeating so multiple boxes on the same screen stay in sync.
class SkeletonBox extends StatelessWidget {
  final Animation<double> shimmer;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    required this.shimmer,
    this.width,
    this.height,
    this.borderRadius = 6,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, __) {
        final t = shimmer.value;
        return Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 - t * 2, 0),
              end: Alignment(1 - t * 2 + 1, 0),
              colors: const [
                Color(0xFFE5E7EB),
                Color(0xFFF3F4F6),
                Color(0xFFE5E7EB),
              ],
              stops: const [0.4, 0.5, 0.6],
            ),
          ),
        );
      },
    );
  }
}

/// Convenience wrapper that owns the shimmer controller. Use this for screens
/// that just want a quick loading phase without managing their own ticker.
class SkeletonHost extends StatefulWidget {
  final Widget Function(BuildContext context, Animation<double> shimmer)
      builder;

  const SkeletonHost({super.key, required this.builder});

  @override
  State<SkeletonHost> createState() => _SkeletonHostState();
}

class _SkeletonHostState extends State<SkeletonHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _shimmer);
}
