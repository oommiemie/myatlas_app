import 'package:flutter/cupertino.dart';

enum AppThemeMode { light, dark, system }

/// Selectable app typefaces. The primary family renders letters (and digits
/// for non-default fonts); the fallbacks cover any missing glyphs (Thai, etc.).
enum AppFont { ibmNunito, sukhumvit, googleSans, sarabun }

class AppFontSpec {
  const AppFontSpec(this.label, this.family, this.fallback);
  final String label;
  final String family;
  final List<String> fallback;
}

const Map<AppFont, AppFontSpec> kAppFontSpecs = {
  // Default: Nunito digits subset + IBM Plex for letters.
  AppFont.ibmNunito:
      AppFontSpec('IBM Plex + Nunito', 'Nunito', ['IBM Plex Sans Thai Looped']),
  AppFont.sukhumvit: AppFontSpec(
      'Sukhumvit', 'Sukhumvit Set', ['Sukhumvit Set', 'IBM Plex Sans Thai Looped']),
  AppFont.googleSans: AppFontSpec(
      'Google Sans', 'Google Sans', ['Google Sans', 'IBM Plex Sans Thai Looped']),
  AppFont.sarabun:
      AppFontSpec('Sarabun', 'Sarabun', ['Sarabun', 'IBM Plex Sans Thai Looped']),
};

/// Simple singleton holding app-wide display settings.
/// Pages read from and write to these notifiers; the root app rebuilds
/// whenever they change.
class AppSettingsService {
  AppSettingsService._();
  static final AppSettingsService instance = AppSettingsService._();

  /// light / dark / system. Dark mode disabled — defaults to (and stays) light.
  final ValueNotifier<AppThemeMode> themeMode =
      ValueNotifier<AppThemeMode>(AppThemeMode.light);

  /// 0.85 .. 1.30 range; discrete 5 steps mapped from slider 0..4.
  final ValueNotifier<double> textScale = ValueNotifier<double>(1.0);

  /// The UI locale. Supported: th, en.
  final ValueNotifier<Locale> locale =
      ValueNotifier<Locale>(const Locale('th', 'TH'));

  /// Selected app typeface. Defaults to IBM Plex (letters) + Nunito (digits).
  final ValueNotifier<AppFont> font = ValueNotifier<AppFont>(AppFont.ibmNunito);
  void setFont(AppFont f) => font.value = f;
  AppFontSpec get fontSpec => kAppFontSpecs[font.value]!;

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
