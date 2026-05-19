import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('default theme mode is system when no preference is saved', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = await ThemeNotifier.create(prefs);

    expect(notifier.state, ThemeMode.system);
    expect(notifier.key, 'auto');
  });

  test('set(ThemeMode.dark) persists and changes state', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = await ThemeNotifier.create(prefs);

    await notifier.set(ThemeMode.dark);

    expect(notifier.state, ThemeMode.dark);
    expect(prefs.getString('theme_mode'), 'dark');
  });

  test('setFromKey("light") persists and changes state', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = await ThemeNotifier.create(prefs);

    await notifier.setFromKey('light');

    expect(notifier.state, ThemeMode.light);
    expect(prefs.getString('theme_mode'), 'light');
  });

  test(
    'theme survives a "restart" (new SharedPreferences instance) — Dark stays Dark',
    () async {
      final prefs1 = await SharedPreferences.getInstance();
      final notifier1 = await ThemeNotifier.create(prefs1);
      await notifier1.set(ThemeMode.dark);

      final prefs2 = await SharedPreferences.getInstance();
      final notifier2 = await ThemeNotifier.create(prefs2);

      expect(notifier2.state, ThemeMode.dark);
    },
  );

  test('unknown keys are rejected', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = await ThemeNotifier.create(prefs);

    final before = notifier.state;
    await notifier.setFromKey('zz');
    expect(notifier.state, before);
    expect(prefs.getString('theme_mode'), isNot('zz'));
  });

  test('ThemeMode.system maps to "auto" key', () {
    expect(ThemeMode.system.toKey(), 'auto');
    expect(ThemeMode.light.toKey(), 'light');
    expect(ThemeMode.dark.toKey(), 'dark');
  });
}
