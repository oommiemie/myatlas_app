import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
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
    return CupertinoApp(
      title: 'MyAtlas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('th', 'TH'),
      supportedLocales: const [
        Locale('th', 'TH'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const MainShell(),
      builder: (context, child) =>
          MiniCallOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
