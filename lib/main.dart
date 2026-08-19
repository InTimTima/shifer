import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'services/app_settings.dart';
import 'theme/shifer_theme.dart';
import 'widgets/shifer_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings();
  await settings.load();
  runApp(ShiferApp(settings: settings));
}

class ShiferApp extends StatelessWidget {
  final AppSettings settings;

  const ShiferApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return ShiferScope(
      settings: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          ShiferTheme.brightness = settings.brightness;
          return MaterialApp(
            title: 'Shifer',
            debugShowCheckedModeBanner: false,
            theme: ShiferTheme.forBrightness(settings.brightness),
            home: const MainShell(),
          );
        },
      ),
    );
  }
}