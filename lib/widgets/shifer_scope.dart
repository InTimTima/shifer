import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/app_settings.dart';

class ShiferScope extends InheritedNotifier<AppSettings> {
  const ShiferScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static AppSettings settingsOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShiferScope>();
    assert(scope != null, 'ShiferScope not found');
    return scope!.notifier!;
  }

  static AppStrings stringsOf(BuildContext context) {
    return AppStrings(settingsOf(context).localeCode);
  }
}
