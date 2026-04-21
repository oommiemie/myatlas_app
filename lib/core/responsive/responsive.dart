import 'package:flutter/cupertino.dart';

enum ScreenSize { compact, regular, large }

class Responsive {
  Responsive._();

  static const double compactMaxWidth = 375;
  static const double regularMaxWidth = 768;

  static ScreenSize sizeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= compactMaxWidth) return ScreenSize.compact;
    if (width <= regularMaxWidth) return ScreenSize.regular;
    return ScreenSize.large;
  }

  static T value<T>(
    BuildContext context, {
    required T compact,
    T? regular,
    T? large,
  }) {
    switch (sizeOf(context)) {
      case ScreenSize.compact:
        return compact;
      case ScreenSize.regular:
        return regular ?? compact;
      case ScreenSize.large:
        return large ?? regular ?? compact;
    }
  }

  static double scaleWidth(BuildContext context, double designWidth,
      {double baseWidth = 390}) {
    final width = MediaQuery.sizeOf(context).width;
    final ratio = (width / baseWidth).clamp(0.85, 1.2);
    return designWidth * ratio;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(context, compact: 16, regular: 20, large: 24),
      vertical: 12,
    );
  }

  static int gridColumns(BuildContext context) {
    return value(context, compact: 2, regular: 2, large: 3);
  }
}
