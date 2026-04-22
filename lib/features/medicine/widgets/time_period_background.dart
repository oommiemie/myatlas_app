import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/time_period.dart';
import 'decorative_elements.dart';

class TimePeriodBackground extends StatelessWidget {
  final TimePeriod period;

  const TimePeriodBackground({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      color: TimePeriodTheme.of(period).backgroundColor,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          ..._decorativeFor(period),
        ],
      ),
    );
  }

  List<Widget> _decorativeFor(TimePeriod p) {
    switch (p) {
      case TimePeriod.morning:
        return const [
          Positioned(
            right: -90,
            top: -60,
            child: DecorativeElements(size: 300),
          ),
        ];
      case TimePeriod.day:
        return [
          Positioned(
            right: -90,
            top: -60,
            child: SvgPicture.asset(
              'assets/svg/deco_day_rainbow.svg',
              width: 300,
              height: 300,
            ),
          ),
        ];
      case TimePeriod.evening:
        return [
          Positioned(
            right: -90,
            top: -60,
            child: SvgPicture.asset(
              'assets/svg/deco_evening_frame1.svg',
              width: 300,
              height: 300,
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
            child: SvgPicture.asset(
              'assets/svg/deco_bedtime_moon.svg',
              width: 300,
              height: 300,
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
