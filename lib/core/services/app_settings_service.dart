import 'package:flutter/cupertino.dart';

enum AppThemeMode { light, dark, system }

/// Simple singleton holding app-wide display settings.
/// Pages read from and write to these notifiers; the root app rebuilds
/// whenever they change.
class AppSettingsService {
  AppSettingsService._();
  static final AppSettingsService instance = AppSettingsService._();

  /// light / dark / system.
  final ValueNotifier<AppThemeMode> themeMode =
      ValueNotifier<AppThemeMode>(AppThemeMode.system);

  /// 0.85 .. 1.30 range; discrete 5 steps mapped from slider 0..4.
  final ValueNotifier<double> textScale = ValueNotifier<double>(1.0);

  /// The UI locale. Supported: th, en.
  final ValueNotifier<Locale> locale =
      ValueNotifier<Locale>(const Locale('th', 'TH'));

  static const List<double> textScaleSteps = <double>[0.85, 0.92, 1.0, 1.12, 1.30];

  void setThemeMode(AppThemeMode mode) => themeMode.value = mode;
  void setFontSizeIndex(int i) =>
      textScale.value = textScaleSteps[i.clamp(0, textScaleSteps.length - 1)];
  int get fontSizeIndex {
    final v = textScale.value;
    var best = 2;
    double bestDiff = double.infinity;
    for (int i = 0; i < textScaleSteps.length; i++) {
      final d = (textScaleSteps[i] - v).abs();
      if (d < bestDiff) {
        bestDiff = d;
        best = i;
      }
    }
    return best;
  }

  void setLocale(Locale l) => locale.value = l;
}
