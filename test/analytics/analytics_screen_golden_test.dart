// Regression goldens for the Analytics tab.
//
// We feed the screen a deterministic dataset whose shape does *not* depend on
// the absolute calendar date: every Monday is `done`, every Tuesday `done`,
// Wednesday `missed`, Thursday `done`, Friday `partial`, Saturday `skipped`,
// Sunday `missed`. As long as the fixture spans many weeks the per-weekday
// aggregates (and therefore the bar / pie / line charts) come out the same on
// any test run.
//
// Two tightly-scoped goldens are used instead of one whole-screen capture:
//   * `analytics_bar_chart.png` — fl_chart BarChart with completion-by-day.
//   * `analytics_pie_chart.png` — fl_chart PieChart with completion-by-category.
//
// Goldens are captured via RepaintBoundary so layout shifts elsewhere on the
// screen (period label, AI card) never invalidate them.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/core/config/theme.dart';
import 'package:habit_flow/core/localization/generated/app_localizations.dart';
import 'package:habit_flow/features/analytics/presentation/analytics_screen.dart';
import 'package:habit_flow/features/habits/data/habit_log_model.dart';
import 'package:habit_flow/features/habits/data/habit_model.dart';
import 'package:habit_flow/features/habits/data/habits_providers.dart';
import 'package:habit_flow/features/habits/domain/habit_log_status.dart';
import 'package:habit_flow/features/habits/domain/habit_type.dart';
import 'package:habit_flow/features/habits/domain/schedule_type.dart';
import 'package:habit_flow/features/journal/data/journal_entry_model.dart';
import 'package:habit_flow/features/journal/data/journal_providers.dart';

// ─── Fixtures ────────────────────────────────────────────────────────────────

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

HabitModel _habit({
  required String id,
  required String name,
  required String category,
  String emoji = '📋',
}) {
  final start = DateTime(2025, 1, 1);
  return HabitModel(
    id: id,
    userId: 'user-golden',
    name: name,
    category: category,
    emoji: emoji,
    type: HabitType.binary,
    scheduleType: ScheduleType.daily,
    startedAt: start,
    createdAt: start,
    updatedAt: start,
  );
}

HabitLogStatus _statusForWeekday(int weekday) {
  // ISO weekday: 1 = Mon … 7 = Sun.
  switch (weekday) {
    case DateTime.monday:
    case DateTime.tuesday:
    case DateTime.thursday:
      return HabitLogStatus.done;
    case DateTime.friday:
      return HabitLogStatus.partial;
    case DateTime.saturday:
      return HabitLogStatus.skipped;
    case DateTime.wednesday:
    case DateTime.sunday:
    default:
      return HabitLogStatus.missed;
  }
}

/// Builds 6 weeks of logs ending on `today`. Status pattern is keyed off the
/// ISO weekday so the resulting per-weekday aggregate is invariant under what
/// the calendar happens to be on the day the test runs.
List<HabitLogModel> _logsFor(String habitId, DateTime today) {
  final out = <HabitLogModel>[];
  final end = _dateOnly(today);
  for (var i = 0; i < 42; i++) {
    final day = end.subtract(Duration(days: i));
    out.add(
      HabitLogModel(
        id: 'log-$habitId-$i',
        userId: 'user-golden',
        habitId: habitId,
        date: day,
        status: _statusForWeekday(day.weekday),
        createdAt: day,
      ),
    );
  }
  return out;
}

List<JournalEntryModel> _journalFixtures(DateTime today) {
  // One mood entry per day for 14 days, alternating high / low so the line
  // chart has both ends populated.
  final out = <JournalEntryModel>[];
  final end = _dateOnly(today);
  for (var i = 0; i < 14; i++) {
    final day = end.subtract(Duration(days: i));
    final mood = (i % 2 == 0) ? 8 : 3;
    final energy = (i % 2 == 0) ? 7 : 4;
    out.add(
      JournalEntryModel(
        id: 'entry-$i',
        userId: 'user-golden',
        date: day,
        mood: mood,
        energy: energy,
        createdAt: day,
        updatedAt: day,
      ),
    );
  }
  return out;
}

// ─── Harness ─────────────────────────────────────────────────────────────────

Widget _harness({
  required List<HabitModel> habits,
  required Map<String, List<HabitLogModel>> logsByHabit,
  required List<JournalEntryModel> entries,
}) {
  return ProviderScope(
    overrides: [
      habitsStreamProvider.overrideWith((ref) => Stream.value(habits)),
      habitLogsForHabitProvider.overrideWith(
        (ref, habitId) =>
            Stream.value(logsByHabit[habitId] ?? const <HabitLogModel>[]),
      ),
      journalEntriesProvider.overrideWith((ref) => Stream.value(entries)),
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
        // Pin the metrics so layout / golden output is reproducible across
        // host resolutions and DPI. 393×852 is the iPhone 14 logical size,
        // a common Telegram Mini App viewport.
        data: const MediaQueryData(
          size: Size(393, 852),
          devicePixelRatio: 1.0,
          textScaler: TextScaler.linear(1.0),
        ),
        child: const Scaffold(body: AnalyticsScreen()),
      ),
    ),
  );
}

void main() {
  // Use the binding's deterministic time origin where possible. fl_chart still
  // calls DateTime.now() during initial layout but it does not influence
  // pixel output in our overrides.
  final today = DateTime(2026, 5, 7); // Thursday — covers all weekdays in the
  // 42-day backfill above.

  group('AnalyticsScreen golden', () {
    testWidgets('bar chart matches fixture', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final habits = [
        _habit(id: 'h1', name: 'Drink water', category: 'health', emoji: '💧'),
        _habit(id: 'h2', name: 'Read', category: 'mind', emoji: '📚'),
      ];
      final logsByHabit = <String, List<HabitLogModel>>{
        'h1': _logsFor('h1', today),
        'h2': _logsFor('h2', today),
      };

      await tester.pumpWidget(_harness(
        habits: habits,
        logsByHabit: logsByHabit,
        entries: _journalFixtures(today),
      ));
      // Two pumps: first lets streams emit, second lets fl_chart settle its
      // animated layout.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      final barFinder = find.byType(BarChart);
      expect(barFinder, findsOneWidget);

      await expectLater(
        barFinder,
        matchesGoldenFile('goldens/analytics_bar_chart.png'),
      );
    });

    testWidgets('pie chart matches fixture', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final habits = [
        _habit(id: 'h1', name: 'Drink water', category: 'health', emoji: '💧'),
        _habit(id: 'h2', name: 'Read', category: 'mind', emoji: '📚'),
      ];
      final logsByHabit = <String, List<HabitLogModel>>{
        'h1': _logsFor('h1', today),
        'h2': _logsFor('h2', today),
      };

      await tester.pumpWidget(_harness(
        habits: habits,
        logsByHabit: logsByHabit,
        entries: _journalFixtures(today),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      final pieFinder = find.byType(PieChart);
      expect(pieFinder, findsOneWidget);

      await expectLater(
        pieFinder,
        matchesGoldenFile('goldens/analytics_pie_chart.png'),
      );
    });
  });

  group('Pearson correlation edges (smoke)', () {
    // The aggregations_test.dart suite already exercises pearsonCorrelation
    // for 1.0, -1.0 and 0.0 cases. This block is intentionally empty as a
    // documentation marker — see aggregations_test.dart for the full set.
    test('see aggregations_test.dart', () {});
  });
}
