import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/app.dart';
import 'package:habit_flow/core/services/locale_service.dart';
import 'package:habit_flow/core/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Splash smoke test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final locale = await LocaleNotifier.create(prefs);
    final theme = await ThemeNotifier.create(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localeProvider.overrideWith((_) => locale),
          themeProvider.overrideWith((_) => theme),
        ],
        child: const HabitFlowApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(HabitFlowApp), findsOneWidget);
  });
}
