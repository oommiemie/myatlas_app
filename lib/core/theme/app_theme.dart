import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static CupertinoThemeData light() {
    final textTheme = _textTheme(AppColors.label);
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      barBackgroundColor: AppColors.surface.withValues(alpha: 0.85),
      textTheme: textTheme,
    );
  }

  static CupertinoThemeData dark() {
    final textTheme = _textTheme(AppColors.labelDark);
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      barBackgroundColor: AppColors.surfaceDark.withValues(alpha: 0.85),
      textTheme: textTheme,
    );
  }

  static CupertinoTextThemeData _textTheme(Color primaryLabel) {
    TextStyle style(double size, FontWeight weight, {Color? color}) =>
        GoogleFonts.dmSans(
          fontSize: size,
          fontWeight: weight,
          color: color ?? primaryLabel,
          height: 1.29,
        );

    return CupertinoTextThemeData(
      primaryColor: primaryLabel,
      textStyle: style(17, FontWeight.w400),
      actionTextStyle: style(17, FontWeight.w400, color: AppColors.primary),
      tabLabelTextStyle: style(10, FontWeight.w500),
      navTitleTextStyle: style(17, FontWeight.w600),
      navLargeTitleTextStyle: style(34, FontWeight.w700),
      navActionTextStyle: style(17, FontWeight.w400, color: AppColors.primary),
      pickerTextStyle: style(21, FontWeight.w400),
      dateTimePickerTextStyle: style(21, FontWeight.w400),
    );
  }
}
