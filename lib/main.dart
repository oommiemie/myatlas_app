import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
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
      home: const MainShell(),
    );
  }
}
