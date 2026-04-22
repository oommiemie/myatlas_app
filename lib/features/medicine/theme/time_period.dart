import 'package:flutter/material.dart';

enum TimePeriod { morning, day, evening, bedtime }

class TimePeriodTheme {
  final Color backgroundColor;

  const TimePeriodTheme({required this.backgroundColor});

  static const _themes = {
    TimePeriod.morning: TimePeriodTheme(backgroundColor: Color(0xFF7CD4FD)),
    TimePeriod.day: TimePeriodTheme(backgroundColor: Color(0xFFFF9C66)),
    TimePeriod.evening: TimePeriodTheme(backgroundColor: Color(0xFFA597C1)),
    TimePeriod.bedtime: TimePeriodTheme(backgroundColor: Color(0xFF0B4A6F)),
  };

  static TimePeriodTheme of(TimePeriod period) => _themes[period]!;
}
