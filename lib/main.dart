import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/app_settings_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/responsive_frame.dart';
import 'features/family/fall_push_overlay.dart';
import 'features/family/mini_call_overlay.dart';
import 'features/shell/main_shell.dart';

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
          builder: (_, locale, __) {
            final platformBrightness = MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first,
            ).platformBrightness;
            final brightness = switch (themeMode) {
              AppThemeMode.light => Brightness.light,
              AppThemeMode.dark => Brightness.dark,
              AppThemeMode.system => platformBrightness,
            };
            return CupertinoApp(
              title: 'MyAtlas',
              debugShowCheckedModeBanner: false,
              theme: brightness == Brightness.dark
                  ? AppTheme.light().copyWith(brightness: Brightness.dark)
                  : AppTheme.light(),
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
                      fontFamily: 'Google Sans',
                      brightness: brightness,
                    ),
                    child: ScaffoldMessenger(
                      child: Material(
                        type: MaterialType.transparency,
                        child: ResponsiveFrame(
                          child: FallPushOverlay(
                            child: MiniCallOverlay(
                              child: child ?? const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              home: const MainShell(),
            );
          },
        ),
      ),
    );
  }
}

