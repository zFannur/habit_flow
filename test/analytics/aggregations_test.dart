import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/analytics/domain/aggregations.dart';
import 'package:habit_flow/features/analytics/domain/date_range.dart';
import 'package:habit_flow/features/analytics/domain/day_of_week.dart';
import 'package:habit_flow/features/analytics/domain/mood_band.dart';
import 'package:habit_flow/features/habits/data/habit_log_model.dart';
import 'package:habit_flow/features/habits/data/habit_model.dart';
import 'package:habit_flow/features/habits/domain/habit_log_status.dart';
import 'package:habit_flow/features/habits/domain/habit_type.dart';
import 'package:habit_flow/features/habits/domain/schedule_type.dart';
import 'package:habit_flow/features/journal/data/journal_entry_model.dart';

// ─── Fixtures ────────────────────────────────────────────────────────────────

DateTime _d(int y, int m, int day) => DateTime(y, m, day);

HabitLogModel _log({
  required DateTime date,
  required HabitLogStatus status,
  String habitId = 'habit-1',
  String id = 'log',
}) {
  return HabitLogModel(
    id: '$id-${date.toIso8601String()}',
    userId: 'user-1',
    habitId: habitId,
    date: date,
    status: status,
    createdAt: date,
  );
}

HabitModel _habit({
  required String id,
  String? category,
}) {
  return HabitModel(
    id: id,
    userId: 'user-1',
    name: 'Habit $id',
    category: category,
    type: HabitType.binary,
    scheduleType: ScheduleType.daily,
    startedAt: _d(2026, 1, 1),
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  );
}

JournalEntryModel _entry({
  required DateTime date,
  int? mood,
}) {
  return JournalEntryModel(
    id: 'entry-${date.toIso8601String()}',
    userId: 'user-1',
    date: date,
    mood: mood,
    createdAt: date,
    updatedAt: date,
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('currentStreak', () {
    test('empty list → 0', () {
      expect(currentStreak(const []), 0);
    });

    test('single done day → 1', () {
      expect(
        currentStreak([_log(date: _d(2026, 5, 1), status: HabitLogStatus.done)]),
        1,
      );
    });

    test('three consecutive done/partial days → 3', () {
      final logs = [
        _log(date: _d(2026, 5, 1), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 2), status: HabitLogStatus.partial),
        _log(date: _d(2026, 5, 3), status: HabitLogStatus.done),
      ];
      expect(currentStreak(logs), 3);
    });

    test('missed day breaks the streak', () {
      final logs = [
        _log(date: _d(2026, 5, 1), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 2), status: HabitLogStatus.missed),
        _log(date: _d(2026, 5, 3), status: HabitLogStatus.done),
      ];
      // Walking back from May 3: done(1) → missed → break.
      expect(currentStreak(logs), 1);
    });

    test('skipped day acts as bridge, does not count', () {
      final logs = [
        _log(date: _d(2026, 5, 1), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 2), status: HabitLogStatus.skipped),
        _log(date: _d(2026, 5, 3), status: HabitLogStatus.done),
      ];
      // 2 successful days; skip is neutral.
      expect(currentStreak(logs), 2);
    });

    test('gap in dates breaks streak', () {
      final logs = [
        _log(date: _d(2026, 5, 1), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 5), status: HabitLogStatus.done),
      ];
      // Walking back from May 5: done(1) → May 4 absent → break.
      expect(currentStreak(logs), 1);
    });
  });

  group('bestStreak', () {
    test('empty → 0', () {
      expect(bestStreak(const []), 0);
    });

    test('single day → 1', () {
      expect(
        bestStreak([_log(date: _d(2026, 5, 1), status: HabitLogStatus.done)]),
        1,
      );
    });

    test('picks the longest of multiple runs', () {
      final logs = [
        // run of 2
        _log(date: _d(2026, 5, 1), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 2), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 3), status: HabitLogStatus.missed),
        // run of 3
        _log(date: _d(2026, 5, 4), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 5), status: HabitLogStatus.partial),
        _log(date: _d(2026, 5, 6), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 7), status: HabitLogStatus.missed),
        // run of 1
        _log(date: _d(2026, 5, 8), status: HabitLogStatus.done),
      ];
      expect(bestStreak(logs), 3);
    });

    test('non-contiguous days are not counted as a single run', () {
      final logs = [
        _log(date: _d(2026, 5, 1), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 3), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 5), status: HabitLogStatus.done),
      ];
      expect(bestStreak(logs), 1);
    });
  });

  group('completionRate', () {
    final period = DateRange(from: _d(2026, 5, 1), to: _d(2026, 5, 7));

    test('empty period → 0', () {
      final empty = DateRange(from: _d(2026, 5, 7), to: _d(2026, 5, 1));
      expect(completionRate(const [], empty), 0);
    });

    test('no logs in range → 0', () {
      expect(completionRate(const [], period), 0);
    });

    test('all 7 days successful → 1.0', () {
      final logs = [
        for (var i = 1; i <= 7; i++)
          _log(date: _d(2026, 5, i), status: HabitLogStatus.done),
      ];
      expect(completionRate(logs, period), 1.0);
    });

    test('logs outside the range are ignored', () {
      final logs = [
        _log(date: _d(2026, 4, 30), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 1), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 8), status: HabitLogStatus.done),
      ];
      // Only May 1 counts → 1/7.
      expect(completionRate(logs, period), closeTo(1 / 7, 1e-9));
    });

    test('skipped/missed do not count as success', () {
      final logs = [
        _log(date: _d(2026, 5, 1), status: HabitLogStatus.skipped),
        _log(date: _d(2026, 5, 2), status: HabitLogStatus.missed),
        _log(date: _d(2026, 5, 3), status: HabitLogStatus.done),
      ];
      expect(completionRate(logs, period), closeTo(1 / 7, 1e-9));
    });
  });

  group('completionByDayOfWeek', () {
    test('empty list → all bands at 0', () {
      final result = completionByDayOfWeek(const []);
      expect(result.length, DayOfWeek.values.length);
      expect(result.values.every((v) => v == 0.0), isTrue);
    });

    test('single Monday done → Monday=1.0, others=0', () {
      // 2026-05-04 is a Monday.
      final logs = [
        _log(date: _d(2026, 5, 4), status: HabitLogStatus.done),
      ];
      final result = completionByDayOfWeek(logs);
      expect(result[DayOfWeek.monday], 1.0);
      expect(result[DayOfWeek.tuesday], 0.0);
    });

    test('mixed success on the same weekday averages correctly', () {
      // Three Mondays: May 4, 11, 18, 2026. 2 done + 1 missed → 2/3.
      final logs = [
        _log(date: _d(2026, 5, 4), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 11), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 18), status: HabitLogStatus.missed),
      ];
      final result = completionByDayOfWeek(logs);
      expect(result[DayOfWeek.monday], closeTo(2 / 3, 1e-9));
    });
  });

  group('completionByCategory', () {
    test('empty habits → empty map', () {
      expect(completionByCategory(const [], const []), isEmpty);
    });

    test('habit with no logs is excluded', () {
      final habits = [_habit(id: 'h1', category: 'health')];
      expect(completionByCategory(habits, const []), isEmpty);
    });

    test('averages habit rates within a category', () {
      final habits = [
        _habit(id: 'h1', category: 'health'),
        _habit(id: 'h2', category: 'health'),
        _habit(id: 'h3', category: 'sport'),
      ];
      final logs = [
        // h1: 1/1 → 1.0
        _log(habitId: 'h1', date: _d(2026, 5, 1), status: HabitLogStatus.done),
        // h2: 1/2 → 0.5
        _log(habitId: 'h2', date: _d(2026, 5, 1), status: HabitLogStatus.done),
        _log(habitId: 'h2', date: _d(2026, 5, 2), status: HabitLogStatus.missed),
        // h3: 0/1 → 0.0
        _log(habitId: 'h3', date: _d(2026, 5, 1), status: HabitLogStatus.missed),
      ];
      final result = completionByCategory(habits, logs);
      expect(result['health'], closeTo((1.0 + 0.5) / 2, 1e-9));
      expect(result['sport'], 0.0);
    });

    test('null category bucketed under empty string', () {
      final habits = [_habit(id: 'h1')];
      final logs = [
        _log(habitId: 'h1', date: _d(2026, 5, 1), status: HabitLogStatus.done),
      ];
      final result = completionByCategory(habits, logs);
      expect(result[''], 1.0);
    });
  });

  group('completionByMood', () {
    test('empty logs → all bands at 0', () {
      final result = completionByMood(const [], const []);
      expect(result[MoodBand.low], 0.0);
      expect(result[MoodBand.high], 0.0);
    });

    test('high mood days correlate with success', () {
      final logs = [
        _log(date: _d(2026, 5, 1), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 2), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 3), status: HabitLogStatus.missed),
      ];
      final entries = [
        _entry(date: _d(2026, 5, 1), mood: 9), // high
        _entry(date: _d(2026, 5, 2), mood: 8), // high
        _entry(date: _d(2026, 5, 3), mood: 2), // low
      ];
      final result = completionByMood(logs, entries);
      expect(result[MoodBand.high], 1.0);
      expect(result[MoodBand.low], 0.0);
      expect(result[MoodBand.mid], 0.0);
    });

    test('logs without a journal entry land in MoodBand.none', () {
      final logs = [
        _log(date: _d(2026, 5, 1), status: HabitLogStatus.done),
        _log(date: _d(2026, 5, 2), status: HabitLogStatus.missed),
      ];
      final result = completionByMood(logs, const []);
      expect(result[MoodBand.none], 0.5);
    });
  });

  group('pearsonCorrelation', () {
    test('different lengths → 0', () {
      expect(pearsonCorrelation(const [1, 2], const [1, 2, 3]), 0);
    });

    test('< 2 samples → 0', () {
      expect(pearsonCorrelation(const [1], const [2]), 0);
      expect(pearsonCorrelation(const [], const []), 0);
    });

    test('zero-variance input → 0', () {
      expect(pearsonCorrelation(const [5, 5, 5], const [1, 2, 3]), 0);
      expect(pearsonCorrelation(const [1, 2, 3], const [7, 7, 7]), 0);
    });

    test('perfect positive correlation → 1.0', () {
      expect(
        pearsonCorrelation(const [1, 2, 3, 4], const [2, 4, 6, 8]),
        closeTo(1.0, 1e-9),
      );
    });

    test('perfect negative correlation → -1.0', () {
      expect(
        pearsonCorrelation(const [1, 2, 3, 4], const [4, 3, 2, 1]),
        closeTo(-1.0, 1e-9),
      );
    });

    test('symmetric anti-pattern → exactly 0', () {
      // x = [-1, 0, 1], y = [1, 0, 1] — symmetric around mean → r = 0.
      final r = pearsonCorrelation(const [-1, 0, 1], const [1, 0, 1]);
      expect(r, closeTo(0.0, 1e-9));
    });
  });

  group('DateRange', () {
    test('weekOf returns Mon..Sun spanning 7 days', () {
      // 2026-05-07 is a Thursday.
      final range = DateRange.weekOf(_d(2026, 5, 7));
      expect(range.from.weekday, DateTime.monday);
      expect(range.to.weekday, DateTime.sunday);
      expect(range.days, 7);
    });

    test('monthOf covers full calendar month', () {
      final range = DateRange.monthOf(_d(2026, 5, 15));
      expect(range.from, _d(2026, 5, 1));
      expect(range.to, _d(2026, 5, 31));
      expect(range.days, 31);
    });

    test('contains is inclusive on both ends', () {
      final r = DateRange(from: _d(2026, 5, 1), to: _d(2026, 5, 3));
      expect(r.contains(_d(2026, 5, 1)), isTrue);
      expect(r.contains(_d(2026, 5, 3)), isTrue);
      expect(r.contains(_d(2026, 4, 30)), isFalse);
      expect(r.contains(_d(2026, 5, 4)), isFalse);
    });
  });
}
