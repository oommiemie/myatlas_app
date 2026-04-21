import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static const String _fallbackFamily = 'DM Sans';

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    double? height,
    double letterSpacing = 0,
    Color color = const Color(0xFF000000),
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle largeTitle(Color color) =>
      _base(size: 34, weight: FontWeight.w700, height: 1.20, color: color);

  static TextStyle title1(Color color) =>
      _base(size: 28, weight: FontWeight.w700, height: 1.21, color: color);

  static TextStyle title2(Color color) =>
      _base(size: 22, weight: FontWeight.w700, height: 1.27, color: color);

  static TextStyle title3(Color color) =>
      _base(size: 20, weight: FontWeight.w600, height: 1.25, color: color);

  static TextStyle headline(Color color) =>
      _base(size: 17, weight: FontWeight.w600, height: 1.29, color: color);

  static TextStyle body(Color color) =>
      _base(size: 17, weight: FontWeight.w400, height: 1.29, color: color);

  static TextStyle callout(Color color) =>
      _base(size: 16, weight: FontWeight.w400, height: 1.31, color: color);

  static TextStyle subheadline(Color color) =>
      _base(size: 15, weight: FontWeight.w400, height: 1.33, color: color);

  static TextStyle footnote(Color color) =>
      _base(size: 13, weight: FontWeight.w400, height: 1.38, color: color);

  static TextStyle caption1(Color color) =>
      _base(size: 12, weight: FontWeight.w400, height: 1.33, color: color);

  static TextStyle caption2(Color color) =>
      _base(size: 11, weight: FontWeight.w400, height: 1.36, color: color);

  static String get fallbackFamily => _fallbackFamily;
}
