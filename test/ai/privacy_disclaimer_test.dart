import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/config/theme.dart';
import 'package:habit_flow/core/localization/generated/app_localizations.dart';
import 'package:habit_flow/features/ai/data/disclaimer_service.dart';
import 'package:habit_flow/features/ai/data/openrouter_key_repository.dart';
import 'package:habit_flow/features/ai/presentation/ai_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── helpers ────────────────────────────────────────────────────────────────

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

// ─── DisclaimerService unit tests ───────────────────────────────────────────

void main() {
  group('DisclaimerService', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('hasSeen() → false при первом запуске', () async {
      final svc = DisclaimerService();
      expect(await svc.hasSeen(), isFalse);
    });

    test('markSeen() + hasSeen() → true', () async {
      final svc = DisclaimerService();
      await svc.markSeen();
      expect(await svc.hasSeen(), isTrue);
    });

    test('reset() сбрасывает флаг', () async {
      final svc = DisclaimerService();
      await svc.markSeen();
      await svc.reset();
      expect(await svc.hasSeen(), isFalse);
    });
  });

  // ─── Widget tests ──────────────────────────────────────────────────────────

  group('AiScreen — privacy disclaimer', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('показывает диалог при первом открытии, если ключ задан', (
      tester,
    ) async {
      final svc = DisclaimerService();

      await tester.pumpWidget(
        _wrap(
          const AiScreen(),
          overrides: [
            disclaimerServiceProvider.overrideWithValue(svc),
            openRouterKeyProvider.overrideWith((_) async => 'sk-or-test'),
          ],
        ),
      );

      // postFrameCallback → async load key + disclaimer check
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('диалог НЕ показывается если ключ не задан', (tester) async {
      final svc = DisclaimerService();

      await tester.pumpWidget(
        _wrap(
          const AiScreen(),
          overrides: [
            disclaimerServiceProvider.overrideWithValue(svc),
            openRouterKeyProvider.overrideWith((_) async => null),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('диалог НЕ показывается если флаг уже задан', (tester) async {
      final svc = DisclaimerService();
      await svc.markSeen();

      await tester.pumpWidget(
        _wrap(
          const AiScreen(),
          overrides: [
            disclaimerServiceProvider.overrideWithValue(svc),
            openRouterKeyProvider.overrideWith((_) async => 'sk-or-test'),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('нажатие "Got it" закрывает диалог и сохраняет флаг', (
      tester,
    ) async {
      final svc = DisclaimerService();

      await tester.pumpWidget(
        _wrap(
          const AiScreen(),
          overrides: [
            disclaimerServiceProvider.overrideWithValue(svc),
            openRouterKeyProvider.overrideWith((_) async => 'sk-or-test'),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AlertDialog), findsOneWidget);

      final btn = find.widgetWithText(TextButton, 'Got it');
      expect(btn, findsOneWidget);
      await tester.tap(btn);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(await svc.hasSeen(), isTrue);
    });
  });
}
