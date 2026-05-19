import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/services/locale_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('default locale is ru when no preference is saved', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = await LocaleNotifier.create(prefs);

    expect(['ru', 'en'], contains(notifier.state.languageCode));
  });

  test('set("en") persists and changes state', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = await LocaleNotifier.create(prefs);

    await notifier.set('en');
    expect(notifier.state.languageCode, 'en');
    expect(prefs.getString('app_locale'), 'en');
  });

  test('locale survives a "restart" (new SharedPreferences instance)', () async {
    final prefs1 = await SharedPreferences.getInstance();
    final notifier1 = await LocaleNotifier.create(prefs1);
    await notifier1.set('en');

    final prefs2 = await SharedPreferences.getInstance();
    final notifier2 = await LocaleNotifier.create(prefs2);

    expect(notifier2.state.languageCode, 'en');
  });

  test('unknown codes are rejected', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = await LocaleNotifier.create(prefs);

    final before = notifier.state.languageCode;
    await notifier.set('zz');
    expect(notifier.state.languageCode, before);
    expect(prefs.getString('app_locale'), isNot('zz'));
  });
}
