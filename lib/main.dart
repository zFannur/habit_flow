import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/services/error_reporter.dart';
import 'core/services/locale_service.dart';
import 'core/services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  ErrorReporter.install();
  Env.assertValid();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  final prefs = await SharedPreferences.getInstance();
  final localeNotifier = await LocaleNotifier.create(prefs);
  final themeNotifier = await ThemeNotifier.create(prefs);
  final accentNotifier = await AccentColorNotifier.create(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localeProvider.overrideWith((_) => localeNotifier),
        themeProvider.overrideWith((_) => themeNotifier),
        accentColorProvider.overrideWith((_) => accentNotifier),
      ],
      child: const HabitFlowApp(),
    ),
  );
}
