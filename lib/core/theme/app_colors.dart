import 'package:flutter/cupertino.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF0A84FF);

  static const Color brandPrimary = Color(0xFF1D8B6B);
  static const Color textTertiary = Color(0xFF6D756E);

  static const Color background = Color(0xFFF4F8F5);
  static const Color backgroundDark = Color(0xFF000000);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  static const Color surfaceSecondary = Color(0xFFF9F9F9);
  static const Color surfaceSecondaryDark = Color(0xFF2C2C2E);

  static const Color label = Color(0xFF000000);
  static const Color labelDark = Color(0xFFFFFFFF);

  static const Color secondaryLabel = Color(0x993C3C43);
  static const Color secondaryLabelDark = Color(0x99EBEBF5);

  static const Color tertiaryLabel = Color(0x4D3C3C43);
  static const Color tertiaryLabelDark = Color(0x4DEBEBF5);

  static const Color separator = Color(0x493C3C43);
  static const Color separatorDark = Color(0x99545458);

  static const Color health = Color(0xFFFF2D55);
  static const Color activity = Color(0xFFFF9500);
  static const Color mindfulness = Color(0xFF5AC8FA);
  static const Color nutrition = Color(0xFF34C759);
  static const Color sleep = Color(0xFFAF52DE);

  // Medicine feature palette
  static const Color bgPrimary = Color(0xFFF4F8F5);
  static const Color bgSurface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF3E453F);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color primary400 = Color(0xFF4AB99C);
  static const Color primary600 = Color(0xFF1D8B6B);
  static const Color info300 = Color(0xFF7CD4FD);
  static const Color success600 = Color(0xFF4CA30D);
  static const Color secondary50 = Color(0xFFFAF7F1);
  static const Color secondary600 = Color(0xFFA88B5B);

  static const Color borderDefault = Color(0xFFE5E5E5);
  static const Color border = Color(0xFFDEDEE0);
  static const Color dateChip = Color(0xFF2C2C2C);
  static const Color inactiveTab = Color(0x993C3C43);

  static Color adaptive(BuildContext context, Color light, Color dark) {
    final brightness = CupertinoTheme.brightnessOf(context);
    return brightness == Brightness.dark ? dark : light;
  }
}
