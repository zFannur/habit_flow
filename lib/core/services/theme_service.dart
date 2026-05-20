import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'theme_mode';

// Сохраняем текстовые ключи, чтобы не зависеть от индексов enum при миграции.
const _modeToString = <ThemeMode, String>{
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
  ThemeMode.system: 'auto',
};

const _stringToMode = <String, ThemeMode>{
  'light': ThemeMode.light,
  'dark': ThemeMode.dark,
  'auto': ThemeMode.system,
};

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._prefs, ThemeMode initial) : super(initial);

  final SharedPreferences _prefs;

  static Future<ThemeNotifier> create(SharedPreferences prefs) async {
    final saved = prefs.getString(_prefsKey);
    final initial = _stringToMode[saved] ?? ThemeMode.system;
    return ThemeNotifier(prefs, initial);
  }

  Future<void> setFromKey(String key) async {
    final mode = _stringToMode[key];
    if (mode == null) return;
    await set(mode);
  }

  Future<void> set(ThemeMode mode) async {
    if (mode != state) state = mode;
    await _prefs.setString(_prefsKey, _modeToString[mode]!);
  }

  /// Текстовый ключ текущего режима (`light` | `dark` | `auto`) — удобно
  /// для UI-переключателя.
  String get key => _modeToString[state]!;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  throw StateError(
    'themeProvider must be overridden in main() '
    'after `await ThemeNotifier.create(prefs)`.',
  );
});

extension ThemeModeKey on ThemeMode {
  /// Текстовый ключ режима — `light` | `dark` | `auto`.
  String toKey() => _modeToString[this]!;
}

// ---------------------------------------------------------------------------
// Accent color
// ---------------------------------------------------------------------------

const _accentPrefsKey = 'theme_accent';

/// Persisted accent color (overrides HFColors.accent in the active theme).
/// `null` means "use the default from HFColors.light/dark".
class AccentColorNotifier extends StateNotifier<Color?> {
  AccentColorNotifier(this._prefs, Color? initial) : super(initial);

  final SharedPreferences _prefs;

  static Future<AccentColorNotifier> create(SharedPreferences prefs) async {
    final saved = prefs.getInt(_accentPrefsKey);
    return AccentColorNotifier(prefs, saved == null ? null : Color(saved));
  }

  Future<void> set(Color? color) async {
    state = color;
    if (color == null) {
      await _prefs.remove(_accentPrefsKey);
    } else {
      // Color.toARGB32 is the modern replacement for the deprecated `value`
      // getter (Flutter 3.27+).
      await _prefs.setInt(_accentPrefsKey, color.toARGB32());
    }
  }
}

final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, Color?>((ref) {
  throw StateError(
    'accentColorProvider must be overridden in main() '
    'after `await AccentColorNotifier.create(prefs)`.',
  );
});
