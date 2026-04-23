import 'package:flutter/widgets.dart';

/// Returns [th] when the current locale is Thai, otherwise [en].
/// Reads the active locale via [Localizations.localeOf] so callers
/// automatically rebuild whenever the app locale changes.
String tr(BuildContext context, String th, String en) {
  final locale = Localizations.maybeLocaleOf(context);
  return (locale?.languageCode == 'en') ? en : th;
}
