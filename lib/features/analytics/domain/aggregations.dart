import 'dart:math' as math;

import '../../habits/data/habit_log_model.dart';
import '../../habits/data/habit_model.dart';
import '../../habits/domain/habit_log_status.dart';
import '../../journal/data/journal_entry_model.dart';
import 'date_range.dart';
import 'day_of_week.dart';
import 'mood_band.dart';

/// Pure aggregation helpers for the Analytics tab.
///
/// All functions are side-effect free and never touch Riverpod or Supabase.
/// They operate on already-fetched lists so they can be unit-tested directly.
///
/// Conventions:
///   * Only the date part of any [DateTime] is considered — the time-of-day
///     component is ignored.
///   * "Successful" day = log exists with status `done` or `partial`.
///   * `skipped` does not count as success but does not break a streak.
///   * `missed` and absent log break the streak.

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _isSuccess(HabitLogStatus s) =>
    s == HabitLogStatus.done || s == HabitLogStatus.partial;

/// Index logs by calendar day. When duplicates exist for the same day the
/// "best" status wins (`done` > `partial` > `skipped` > `missed`) so a single
/// late correction does not undo an earlier success.
Map<DateTime, HabitLogStatus> _statusByDay(List<HabitLogModel> logs) {
  const rank = <HabitLogStatus, int>{
    HabitLogStatus.done: 3,
    HabitLogStatus.partial: 2,
    HabitLogStatus.skipped: 1,
    HabitLogStatus.missed: 0,
  };
  final out = <DateTime, HabitLogStatus>{};
  for (final l in logs) {
    final d = _dateOnly(l.date);
    final existing = out[d];
    if (existing == null || (rank[l.status] ?? 0) > (rank[existing] ?? 0)) {
      out[d] = l.status;
    }
  }
  return out;
}

// ─────────────────────────────────────────────────────────────────────────────
// Streaks
// ─────────────────────────────────────────────────────────────────────────────

/// Current streak: consecutive successful days ending at the most-recent log.
///
/// Walks backwards from the latest log date and counts while the status is
/// `done` or `partial`. `skipped` keeps the streak alive but does not count;
/// `missed` or an absent day terminates the walk.
int currentStreak(List<HabitLogModel> logs) {
  if (logs.isEmpty) return 0;
  final byDay = _statusByDay(logs);
  if (byDay.isEmpty) return 0;

  // Start at the latest day that appears in the logs.
  final sortedDays = byDay.keys.toList()..sort();
  var cursor = sortedDays.last;
  var streak = 0;
  // Hard cap to prevent pathological data from infinite-looping.
  const maxIterations = 3650;
  var i = 0;

  while (i < maxIterations) {
    i++;
    final status = byDay[cursor];
    if (status == null) break;
    if (status == HabitLogStatus.missed) break;
    if (_isSuccess(status)) {
      streak++;
    }
    // For skipped: don't increment, keep walking.
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// Best (longest) streak ever observed in [logs].
///
/// Iterates over all distinct days in chronological order and tracks the
/// longest run of consecutive successful days. `skipped` is treated as a
/// neutral bridge (does not count, does not break).
int bestStreak(List<HabitLogModel> logs) {
  if (logs.isEmpty) return 0;
  final byDay = _statusByDay(logs);
  final days = byDay.keys.toList()..sort();
  if (days.isEmpty) return 0;

  var best = 0;
  var run = 0;
  DateTime? prev;

  for (final d in days) {
    final status = byDay[d]!;
    final isContiguous =
        prev == null || d.difference(prev).inDays == 1;
    if (status == HabitLogStatus.missed) {
      run = 0;
      prev = d;
      continue;
    }
    if (!isContiguous) {
      run = 0;
    }
    if (_isSuccess(status)) {
      run++;
      if (run > best) best = run;
    }
    // skipped: keep `run` as-is, treat as bridge.
    prev = d;
  }
  return best;
}

// ─────────────────────────────────────────────────────────────────────────────
// Completion rates
// ─────────────────────────────────────────────────────────────────────────────

/// Fraction of scheduled habits completed in [period].
/// Range: `[0.0, 1.0]`. Returns 0 for empty periods.
double completionRate(List<HabitLogModel> logs, DateRange period) {
  final logsInRange = logs.where((l) => period.contains(_dateOnly(l.date))).toList();
  if (logsInRange.isEmpty) return 0.0;
  final ok = logsInRange.where((l) => _isSuccess(l.status)).length;
  return ok / logsInRange.length;
}

/// Completion rate per ISO weekday.
///
/// For each weekday: `(successful logs with that weekday) /
/// (total logs with that weekday)`.
///
/// Weekdays with zero logs are still emitted with value `0.0` so callers can
/// render a complete 7-bar chart.
Map<DayOfWeek, double> completionByDayOfWeek(List<HabitLogModel> logs) {
  final result = <DayOfWeek, double>{
    for (final d in DayOfWeek.values) d: 0.0,
  };
  if (logs.isEmpty) return result;

  final logsByDow = <DayOfWeek, List<HabitLogModel>>{};
  for (final l in logs) {
    final dow = DayOfWeek.fromDateTime(_dateOnly(l.date));
    logsByDow.putIfAbsent(dow, () => <HabitLogModel>[]).add(l);
  }

  for (final dow in DayOfWeek.values) {
    final list = logsByDow[dow];
    if (list == null || list.isEmpty) continue;
    final ok = list.where((l) => _isSuccess(l.status)).length;
    result[dow] = ok / list.length;
  }
  return result;
}

/// Completion rate per category label.
///
/// Each habit contributes its own success rate (`successful logs / total
/// logs`). The function returns the mean rate per category — categories with
/// no habits are omitted.
///
/// Habits without a [HabitModel.category] are bucketed under the empty string
/// `''` so callers can decide how to render "uncategorised".
Map<String, double> completionByCategory(
  List<HabitModel> habits,
  List<HabitLogModel> logs,
) {
  if (habits.isEmpty) return <String, double>{};

  // Group logs by habit id for O(1) lookup.
  final logsByHabit = <String, List<HabitLogModel>>{};
  for (final l in logs) {
    logsByHabit.putIfAbsent(l.habitId, () => <HabitLogModel>[]).add(l);
  }

  final ratesByCategory = <String, List<double>>{};
  for (final h in habits) {
    final habitLogs = logsByHabit[h.id] ?? const <HabitLogModel>[];
    if (habitLogs.isEmpty) continue;
    final ok = habitLogs.where((l) => _isSuccess(l.status)).length;
    final rate = ok / habitLogs.length;
    final key = h.category ?? '';
    ratesByCategory.putIfAbsent(key, () => <double>[]).add(rate);
  }

  return ratesByCategory.map(
    (k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length),
  );
}

/// Completion rate bucketed by the user's mood on the same calendar day.
///
/// For every successful habit log we look up the journal entry on that day:
///   * mood ≤ 4 → [MoodBand.low]
///   * mood 5..6 → [MoodBand.mid]
///   * mood ≥ 7 → [MoodBand.high]
///   * no entry → [MoodBand.none]
///
/// Returns `(successful days in band) / (total tracked days in band)`.
Map<MoodBand, double> completionByMood(
  List<HabitLogModel> logs,
  List<JournalEntryModel> entries,
) {
  final result = <MoodBand, double>{
    for (final b in MoodBand.values) b: 0.0,
  };
  if (logs.isEmpty) return result;

  final moodByDay = <DateTime, int?>{};
  for (final e in entries) {
    moodByDay[_dateOnly(e.date)] = e.mood;
  }

  final byDay = _statusByDay(logs);
  final seenByBand = <MoodBand, int>{};
  final okByBand = <MoodBand, int>{};

  for (final entry in byDay.entries) {
    final day = entry.key;
    final status = entry.value;
    final band = MoodBand.fromMood(moodByDay[day]);
    seenByBand.update(band, (v) => v + 1, ifAbsent: () => 1);
    if (_isSuccess(status)) {
      okByBand.update(band, (v) => v + 1, ifAbsent: () => 1);
    }
  }

  for (final band in MoodBand.values) {
    final total = seenByBand[band] ?? 0;
    if (total == 0) continue;
    result[band] = (okByBand[band] ?? 0) / total;
  }
  return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// Pearson correlation
// ─────────────────────────────────────────────────────────────────────────────

/// Pearson correlation coefficient between paired samples [x] and [y].
///
/// Returns 0 when:
///   * the lists differ in length,
///   * fewer than 2 samples are provided,
///   * either series has zero variance (constant value).
///
/// The result is in `[-1.0, 1.0]`.
double pearsonCorrelation(List<num> x, List<num> y) {
  if (x.length != y.length) return 0;
  final n = x.length;
  if (n < 2) return 0;

  var sumX = 0.0;
  var sumY = 0.0;
  for (var i = 0; i < n; i++) {
    sumX += x[i];
    sumY += y[i];
  }
  final meanX = sumX / n;
  final meanY = sumY / n;

  var num_ = 0.0;
  var denX = 0.0;
  var denY = 0.0;
  for (var i = 0; i < n; i++) {
    final dx = x[i] - meanX;
    final dy = y[i] - meanY;
    num_ += dx * dy;
    denX += dx * dx;
    denY += dy * dy;
  }
  if (denX == 0 || denY == 0) return 0;
  return num_ / math.sqrt(denX * denY);
}
