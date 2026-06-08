import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/theme.dart';
import 'core/localization/generated/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/services/locale_service.dart';
import 'core/services/telegram_chrome.dart';
import 'core/services/theme_service.dart';

class HabitFlowApp extends ConsumerWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    final accent = ref.watch(accentColorProvider);
    final tgBrightness = ref.watch(telegramBrightnessProvider);

    // В режиме «системная тема» следуем за Telegram (`WebApp.colorScheme`),
    // если он доступен, иначе — за platform-brightness (поведение по умолчанию).
    final effectiveThemeMode = themeMode == ThemeMode.system && tgBrightness != null
        ? (tgBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light)
        : themeMode;

    return MaterialApp.router(
      title: 'HabitFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accentOverride: accent),
      darkTheme: AppTheme.dark(accentOverride: accent),
      themeMode: effectiveThemeMode,
      routerConfig: router,
      builder: (context, child) =>
          TelegramChrome(child: child ?? const SizedBox.shrink()),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
