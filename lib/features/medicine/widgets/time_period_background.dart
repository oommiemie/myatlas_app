import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/time_period.dart';
import 'decorative_elements.dart';

class TimePeriodBackground extends StatefulWidget {
  final TimePeriod period;

  const TimePeriodBackground({super.key, required this.period});

  @override
  State<TimePeriodBackground> createState() => _TimePeriodBackgroundState();
}

class _TimePeriodBackgroundState extends State<TimePeriodBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbCtrl;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _orbCtrl.forward());
  }

  @override
  void didUpdateWidget(covariant TimePeriodBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _orbCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      color: TimePeriodTheme.of(widget.period).backgroundColor,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: _decorativeFor(widget.period),
      ),
    );
  }

  Widget _animatedOrb({required Widget child}) {
    return AnimatedBuilder(
      animation: _orbCtrl,
      builder: (_, inner) {
        final t = Curves.easeOutCubic.transform(_orbCtrl.value);
        final dy = (1 - t) * 120;
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, dy), child: inner),
        );
      },
      child: child,
    );
  }

  List<Widget> _decorativeFor(TimePeriod p) {
    switch (p) {
      case TimePeriod.morning:
        return [
          Positioned(
            right: -90,
            top: -60,
            child: _animatedOrb(child: const DecorativeElements(size: 300)),
          ),
        ];
      case TimePeriod.day:
        return [
          Positioned(
            right: -90,
            top: -60,
            child: _animatedOrb(
              child: SvgPicture.asset(
                'assets/svg/deco_day_rainbow.svg',
                width: 300,
                height: 300,
              ),
            ),
          ),
        ];
      case TimePeriod.evening:
        return [
          Positioned(
            right: -90,
            top: -60,
            child: _animatedOrb(
              child: SvgPicture.asset(
                'assets/svg/deco_evening_frame1.svg',
                width: 300,
                height: 300,
              ),
            ),
          ),
          Positioned(
            right: 150,
            top: 18,
            child: SvgPicture.asset(
              'assets/svg/deco_evening_frame.svg',
              width: 27,
              height: 45,
            ),
          ),
        ];
      case TimePeriod.bedtime:
        return [
          Positioned(
            right: -90,
            top: -60,
            child: _animatedOrb(
              child: SvgPicture.asset(
                'assets/svg/deco_bedtime_moon.svg',
                width: 300,
                height: 300,
              ),
            ),
          ),
          Positioned(
            right: 150,
            top: 16,
            child: SvgPicture.asset(
              'assets/svg/deco_bedtime_dots.svg',
              width: 74,
              height: 49,
            ),
          ),
        ];
    }
  }
}
