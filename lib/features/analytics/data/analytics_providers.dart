import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../habits/data/habit_log_model.dart';
import '../../habits/data/habit_model.dart';
import '../../habits/data/habits_providers.dart';
import '../../journal/data/journal_entry_model.dart';
import '../../journal/data/journal_providers.dart';
import '../domain/aggregations.dart';
import '../domain/date_range.dart';
import '../domain/day_of_week.dart';
import '../domain/mood_band.dart';

/// Bundle of stats computed for one [DateRange]. The screen consumes this
/// directly — every metric the analytics tab renders is derived from these
/// fields plus the live habits/journal lists.
class AnalyticsStats {
  const AnalyticsStats({
    required this.range,
    required this.completionRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.byDayOfWeek,
    required this.byCategory,
    required this.byMood,
    required this.moodCompletionCorrelation,
  });

  final DateRange range;
  final double completionRate;
  final int currentStreak;
  final int bestStreak;
  final Map<DayOfWeek, double> byDayOfWeek;
  final Map<String, double> byCategory;
  final Map<MoodBand, double> byMood;

  /// Pearson r between daily mood (1..10) and that day's completion rate
  /// across all logged habits. Range `[-1, 1]`. `0` when sample size < 2 or
  /// either series is constant.
  final double moodCompletionCorrelation;
}

/// Computes per-day completion rate vs. mood and returns Pearson r. Pulls
/// only the days that have both a journal entry and at least one log so the
/// correlation is not dominated by zero-padding.
double _moodCompletionCorrelation(
  List<HabitLogModel> logs,
  List<JournalEntryModel> entries,
) {
  if (logs.isEmpty || entries.isEmpty) return 0;

  // For each day with a journal mood, compute completion rate of that day's
  // logs (= success / total across all habits logged that day).
  DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  final moodByDay = <DateTime, int>{};
  for (final e in entries) {
    final m = e.mood;
    if (m == null) continue;
    moodByDay[dateOnly(e.date)] = m;
  }
  if (moodByDay.isEmpty) return 0;

  final logsByDay = <DateTime, List<HabitLogModel>>{};
  for (final l in logs) {
    logsByDay.putIfAbsent(dateOnly(l.date), () => <HabitLogModel>[]).add(l);
  }

  final xs = <num>[];
  final ys = <num>[];
  for (final day in moodByDay.keys) {
    final dayLogs = logsByDay[day];
    if (dayLogs == null || dayLogs.isEmpty) continue;
    final ok = dayLogs.where((l) => l.isDone || l.isPartial).length;
    final rate = ok / dayLogs.length;
    xs.add(moodByDay[day]!);
    ys.add(rate);
  }
  return pearsonCorrelation(xs, ys);
}

/// Internal helper that turns a [DateRange] into an [AnalyticsStats]. Reads
/// from the existing realtime providers so the result stays live.
AnalyticsStats _statsFor(Ref ref, DateRange range) {
  final habits = ref.watch(habitsStreamProvider).valueOrNull ?? const <HabitModel>[];
  final entries =
      ref.watch(journalEntriesProvider).valueOrNull ?? const <JournalEntryModel>[];

  // Logs are exposed per-habit as streams. We collect all currently-known
  // logs by reading each habit's stream snapshot. Logs outside [range] are
  // filtered down-stream by the aggregation helpers.
  final allLogs = <HabitLogModel>[];
  for (final h in habits) {
    final async = ref.watch(habitLogsForHabitProvider(h.id));
    final list = async.valueOrNull;
    if (list != null) allLogs.addAll(list);
  }

  final logsInRange = allLogs.where((l) => range.contains(l.date)).toList();

  return AnalyticsStats(
    range: range,
    completionRate: completionRate(logsInRange, range),
    currentStreak: currentStreak(logsInRange),
    bestStreak: bestStreak(logsInRange),
    byDayOfWeek: completionByDayOfWeek(logsInRange),
    byCategory: completionByCategory(habits, logsInRange),
    byMood: completionByMood(
      logsInRange,
      entries.where((e) => range.contains(e.date)).toList(),
    ),
    moodCompletionCorrelation: _moodCompletionCorrelation(
      logsInRange,
      entries.where((e) => range.contains(e.date)).toList(),
    ),
  );
}

/// Stats for the ISO week (Mon..Sun) containing [day].
final weeklyStatsProvider = Provider.family<AnalyticsStats, DateTime>(
  (ref, day) => _statsFor(ref, DateRange.weekOf(day)),
);

/// Stats for the calendar month containing [day].
final monthlyStatsProvider = Provider.family<AnalyticsStats, DateTime>(
  (ref, day) => _statsFor(ref, DateRange.monthOf(day)),
);
