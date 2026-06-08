import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/services/error_reporter.dart';
import 'core/services/locale_service.dart';
import 'core/services/telegram_chrome.dart';
import 'core/services/telegram_service.dart';
import 'core/services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorReporter.install();
  await Env.load();
  Env.assertValid();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  final prefs = await SharedPreferences.getInstance();
  final localeNotifier = await LocaleNotifier.create(prefs);
  final themeNotifier = await ThemeNotifier.create(prefs);
  final accentNotifier = await AccentColorNotifier.create(prefs);
  // Снимок темы Telegram до первого кадра — чтобы «системная» тема сразу
  // открылась в правильной яркости без вспышки (обновляется в TelegramChrome).
  final tgBrightness = const TelegramService().telegramBrightness();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localeProvider.overrideWith((_) => localeNotifier),
        themeProvider.overrideWith((_) => themeNotifier),
        accentColorProvider.overrideWith((_) => accentNotifier),
        telegramBrightnessProvider.overrideWith((_) => tgBrightness),
      ],
      child: const HabitFlowApp(),
    ),
  );
}
