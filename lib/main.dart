import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/app_settings_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/family/fall_push_overlay.dart';
import 'features/family/mini_call_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const MyAtlasApp());
}


class MyAtlasApp extends StatelessWidget {
  const MyAtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsService.instance;
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: settings.themeMode,
      builder: (_, themeMode, __) =>
          ValueListenableBuilder<double>(
        valueListenable: settings.textScale,
        builder: (_, textScale, __) =>
            ValueListenableBuilder<Locale>(
          valueListenable: settings.locale,
          builder: (_, locale, __) =>
              ValueListenableBuilder<AppFont>(
            valueListenable: settings.font,
            builder: (_, font, __) {
            // Dark mode disabled — the app always runs in light mode
            // regardless of the saved theme setting or system brightness.
            const brightness = Brightness.light;
            final fontSpec = settings.fontSpec;
            return CupertinoApp(
              title: 'MyAtlas',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              locale: locale,
              supportedLocales: const [
                Locale('th', 'TH'),
                Locale('en', 'US'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                final mq = MediaQuery.of(context);
                return MediaQuery(
                  data: mq.copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: Theme(
                    data: ThemeData(
                      // Follows the user's font selection.
                      fontFamily: fontSpec.family,
                      fontFamilyFallback: fontSpec.fallback,
                      brightness: brightness,
                    ),
                    child: ScaffoldMessenger(
                      child: Material(
                        type: MaterialType.transparency,
                        child: FallPushOverlay(
                          child: MiniCallOverlay(
                            child: child ?? const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              home: const LoginScreen(),
            );
            },
          ),
        ),
      ),
    );
  }
}

