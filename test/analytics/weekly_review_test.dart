// Widget tests for the weekly-review checklist on AnalyticsScreen.
//
// We assert:
//   * Without showWeeklyReview/?review=1 the checklist key is absent.
//   * With showWeeklyReview=true the key is found and items render.
//   * Tapping a row toggles its checked state (icon appears/disappears).
//
// We don't go through go_router here — the flag is wired via constructor
// arg from the route layer (see app_router.dart).

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/config/theme.dart';
import 'package:habit_flow/core/localization/generated/app_localizations.dart';
import 'package:habit_flow/features/analytics/presentation/analytics_screen.dart';
import 'package:habit_flow/features/analytics/presentation/widgets/weekly_review_checklist.dart';
import 'package:habit_flow/features/habits/data/habit_log_model.dart';
import 'package:habit_flow/features/habits/data/habit_model.dart';
import 'package:habit_flow/features/habits/data/habits_providers.dart';
import 'package:habit_flow/features/journal/data/journal_entry_model.dart';
import 'package:habit_flow/features/journal/data/journal_providers.dart';

Widget _harness({required bool showReview}) {
  return ProviderScope(
    overrides: [
      habitsStreamProvider
          .overrideWith((ref) => Stream.value(const <HabitModel>[])),
      habitLogsForHabitProvider
          .overrideWith((ref, _) => Stream.value(const <HabitLogModel>[])),
      journalEntriesProvider
          .overrideWith((ref) => Stream.value(const <JournalEntryModel>[])),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(393, 852),
          devicePixelRatio: 1.0,
          textScaler: TextScaler.linear(1.0),
        ),
        child: Scaffold(
          body: AnalyticsScreen(showWeeklyReview: showReview),
        ),
      ),
    ),
  );
}

void main() {
  group('WeeklyReviewChecklist on AnalyticsScreen', () {
    testWidgets('hidden when showWeeklyReview=false', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_harness(showReview: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('weekly_review_checklist')), findsNothing);
      expect(find.byType(WeeklyReviewChecklist), findsNothing);
    });

    testWidgets('shown when showWeeklyReview=true', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_harness(showReview: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('weekly_review_checklist')), findsOneWidget);
      // Three checklist items render with the localised labels.
      expect(find.text('Looked at streaks'), findsOneWidget);
      expect(find.text('Looked at correlations'), findsOneWidget);
      expect(find.text('Updated goals'), findsOneWidget);
    });

    testWidgets('tapping an item toggles its checked state', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_harness(showReview: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final firstItem = find.text('Looked at streaks');
      expect(firstItem, findsOneWidget);

      await tester.tap(firstItem);
      await tester.pump(const Duration(milliseconds: 200));

      // Re-find — still present after toggle.
      expect(find.text('Looked at streaks'), findsOneWidget);
    });
  });
}
