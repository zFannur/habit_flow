import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'app_locale';
const _supportedCodes = {'ru', 'en'};

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs, Locale initial) : super(initial);

  final SharedPreferences _prefs;

  static Future<LocaleNotifier> create(SharedPreferences prefs) async {
    final saved = prefs.getString(_prefsKey);
    final platform = PlatformDispatcher.instance.locale.languageCode;
    final code = saved != null && _supportedCodes.contains(saved)
        ? saved
        : (_supportedCodes.contains(platform) ? platform : 'ru');
    return LocaleNotifier(prefs, Locale(code));
  }

  Future<void> set(String code) async {
    if (!_supportedCodes.contains(code)) return;
    if (code != state.languageCode) state = Locale(code);
    await _prefs.setString(_prefsKey, code);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main()'),
);

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  throw UnimplementedError('Override in main() with LocaleNotifier.create');
});
