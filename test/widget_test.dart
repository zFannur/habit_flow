import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/app.dart';
import 'package:habit_flow/core/services/locale_service.dart';
import 'package:habit_flow/core/services/supabase_service.dart';
import 'package:habit_flow/core/services/telegram_service.dart';
import 'package:habit_flow/core/services/theme_service.dart';
import 'package:habit_flow/features/auth/data/auth_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSupabaseService extends Mock implements SupabaseService {}
class _MockTelegramService extends Mock implements TelegramService {}

void main() {
  testWidgets('Splash smoke test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final locale = await LocaleNotifier.create(prefs);
    final theme = await ThemeNotifier.create(prefs);
    final accent = await AccentColorNotifier.create(prefs);

    final mockSupabase = _MockSupabaseService();
    final mockTelegram = _MockTelegramService();

    when(() => mockTelegram.getInitData()).thenReturn('');
    // TelegramChrome (mounted via MaterialApp.router builder) drives the
    // native chrome through these — stub the non-void returns so the mock
    // doesn't hand back null for a non-nullable VoidCallback.
    when(() => mockTelegram.telegramBrightness()).thenReturn(null);
    when(() => mockTelegram.onThemeChanged(any())).thenReturn(() {});
    when(() => mockTelegram.showBackButton(any())).thenReturn(() {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localeProvider.overrideWith((_) => locale),
          themeProvider.overrideWith((_) => theme),
          accentColorProvider.overrideWith((_) => accent),
          supabaseServiceProvider.overrideWithValue(mockSupabase),
          telegramServiceProvider.overrideWithValue(mockTelegram),
        ],
        child: const HabitFlowApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(HabitFlowApp), findsOneWidget);
  });
}
