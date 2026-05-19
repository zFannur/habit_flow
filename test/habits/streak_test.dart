import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/habits/data/habit_log_model.dart';
import 'package:habit_flow/features/habits/data/habit_model.dart';
import 'package:habit_flow/features/habits/domain/habit_calculations.dart';
import 'package:habit_flow/features/habits/domain/habit_log_status.dart';
import 'package:habit_flow/features/habits/domain/habit_type.dart';
import 'package:habit_flow/features/habits/domain/schedule_type.dart';

HabitModel _habit({
  ScheduleType scheduleType = ScheduleType.daily,
  Map<String, dynamic> schedule = const <String, dynamic>{},
  DateTime? startedAt,
}) {
  final start = startedAt ?? DateTime(2026, 1, 1);
  return HabitModel(
    id: 'h1',
    userId: 'u1',
    name: 'Test',
    type: HabitType.binary,
    scheduleType: scheduleType,
    schedule: schedule,
    startedAt: start,
    createdAt: start,
    updatedAt: start,
  );
}

HabitModel _stackHabit({
  required String id,
  required String name,
  String? stackAfter,
}) {
  final now = DateTime(2026, 1, 1);
  return HabitModel(
    id: id,
    userId: 'u1',
    name: name,
    type: HabitType.binary,
    scheduleType: ScheduleType.daily,
    startedAt: now,
    createdAt: now,
    updatedAt: now,
    stackAfterHabitId: stackAfter,
  );
}

HabitLogModel _log(DateTime date, HabitLogStatus status) {
  return HabitLogModel(
    id: 'log-${date.toIso8601String()}',
    userId: 'u1',
    habitId: 'h1',
    date: date,
    status: status,
    createdAt: date,
  );
}

void main() {
  group('currentStreak', () {
    final today = DateTime(2026, 5, 7); // Thursday

    test('empty logs and not scheduled today → 0', () {
      // Habit only on Mondays; today is Thursday.
      final habit = _habit(
        scheduleType: ScheduleType.weekdays,
        schedule: {'weekdays': [1]},
      );
      expect(
        currentStreak(habit: habit, logs: const [], today: today),
        0,
      );
    });

    test('empty logs but scheduled today → 0', () {
      final habit = _habit();
      expect(currentStreak(habit: habit, logs: const [], today: today), 0);
    });

    test('today done, yesterday done → 2', () {
      final habit = _habit();
      final logs = [
        _log(DateTime(2026, 5, 7), HabitLogStatus.done),
        _log(DateTime(2026, 5, 6), HabitLogStatus.done),
      ];
      expect(currentStreak(habit: habit, logs: logs, today: today), 2);
    });

    test('today not logged yet, yesterday done → 1 (today is grace day)', () {
      final habit = _habit();
      final logs = [_log(DateTime(2026, 5, 6), HabitLogStatus.done)];
      expect(currentStreak(habit: habit, logs: logs, today: today), 1);
    });

    test('partial counts as streak day', () {
      final habit = _habit();
      final logs = [
        _log(DateTime(2026, 5, 7), HabitLogStatus.partial),
        _log(DateTime(2026, 5, 6), HabitLogStatus.done),
      ];
      expect(currentStreak(habit: habit, logs: logs, today: today), 2);
    });

    test('skipped keeps streak alive but does not count', () {
      final habit = _habit();
      final logs = [
        _log(DateTime(2026, 5, 7), HabitLogStatus.done),
        _log(DateTime(2026, 5, 6), HabitLogStatus.skipped),
        _log(DateTime(2026, 5, 5), HabitLogStatus.done),
      ];
      // 7-th counts, 6-th skipped (no count), 5-th counts → streak = 2.
      expect(currentStreak(habit: habit, logs: logs, today: today), 2);
    });

    test('missed in the middle breaks streak', () {
      final habit = _habit();
      final logs = [
        _log(DateTime(2026, 5, 7), HabitLogStatus.done),
        _log(DateTime(2026, 5, 6), HabitLogStatus.missed),
        _log(DateTime(2026, 5, 5), HabitLogStatus.done),
      ];
      expect(currentStreak(habit: habit, logs: logs, today: today), 1);
    });

    test('absent log on a scheduled day before today breaks streak', () {
      final habit = _habit();
      final logs = [
        _log(DateTime(2026, 5, 7), HabitLogStatus.done),
        // 2026-05-06 missing entirely
        _log(DateTime(2026, 5, 5), HabitLogStatus.done),
      ];
      expect(currentStreak(habit: habit, logs: logs, today: today), 1);
    });

    test('unscheduled days are skipped without breaking streak', () {
      // Habit on Mon/Wed/Fri only.
      final habit = _habit(
        scheduleType: ScheduleType.weekdays,
        schedule: {'weekdays': [1, 3, 5]},
      );
      // 2026-05-07 = Thu (not scheduled), 2026-05-06 = Wed, 2026-05-04 = Mon.
      final logs = [
        _log(DateTime(2026, 5, 6), HabitLogStatus.done),
        _log(DateTime(2026, 5, 4), HabitLogStatus.done),
      ];
      // Walk: Thu (skip), Wed done +1, Tue (skip), Mon done +1 → 2.
      expect(currentStreak(habit: habit, logs: logs, today: today), 2);
    });

    test('streak stops at habit start date', () {
      final habit = _habit(startedAt: DateTime(2026, 5, 6));
      final logs = [
        _log(DateTime(2026, 5, 7), HabitLogStatus.done),
        _log(DateTime(2026, 5, 6), HabitLogStatus.done),
      ];
      expect(currentStreak(habit: habit, logs: logs, today: today), 2);
    });

    test('logs only in the distant past → 0', () {
      final habit = _habit();
      final logs = [_log(DateTime(2026, 4, 1), HabitLogStatus.done)];
      expect(currentStreak(habit: habit, logs: logs, today: today), 0);
    });

    test('every_n_days cadence — only scheduled days count', () {
      final habit = _habit(
        scheduleType: ScheduleType.everyNDays,
        schedule: {'every_n': 2},
        startedAt: DateTime(2026, 5, 1), // Fri
      );
      // Scheduled: 5/1, 5/3, 5/5, 5/7. Today = 5/7 (Thu).
      final logs = [
        _log(DateTime(2026, 5, 7), HabitLogStatus.done),
        _log(DateTime(2026, 5, 5), HabitLogStatus.done),
        _log(DateTime(2026, 5, 3), HabitLogStatus.done),
      ];
      expect(currentStreak(habit: habit, logs: logs, today: today), 3);
    });
  });

  group('buildHeatmap', () {
    test('returns map keyed by date (no time component)', () {
      final today = DateTime(2026, 5, 7);
      final logs = [
        _log(DateTime(2026, 5, 7), HabitLogStatus.done),
        _log(DateTime(2026, 5, 6), HabitLogStatus.partial),
        _log(DateTime(2026, 5, 1), HabitLogStatus.missed),
      ];
      final heatmap = buildHeatmap(logs: logs, today: today, daysBack: 7);
      expect(heatmap[DateTime(2026, 5, 7)], HabitLogStatus.done);
      expect(heatmap[DateTime(2026, 5, 6)], HabitLogStatus.partial);
      expect(heatmap[DateTime(2026, 5, 1)], HabitLogStatus.missed);
      expect(heatmap.length, 3);
    });

    test('logs older than daysBack are excluded', () {
      final today = DateTime(2026, 5, 7);
      final logs = [
        _log(DateTime(2026, 5, 7), HabitLogStatus.done),
        // daysBack=3 → cutoff 5/5.
        _log(DateTime(2026, 5, 4), HabitLogStatus.done),
      ];
      final heatmap = buildHeatmap(logs: logs, today: today, daysBack: 3);
      expect(heatmap.containsKey(DateTime(2026, 5, 4)), isFalse);
      expect(heatmap.containsKey(DateTime(2026, 5, 7)), isTrue);
    });

    test('future-dated logs are excluded', () {
      final today = DateTime(2026, 5, 7);
      final logs = [
        _log(DateTime(2026, 5, 8), HabitLogStatus.done), // future, ignore
        _log(DateTime(2026, 5, 7), HabitLogStatus.done),
      ];
      final heatmap = buildHeatmap(logs: logs, today: today, daysBack: 7);
      expect(heatmap.length, 1);
      expect(heatmap[DateTime(2026, 5, 7)], HabitLogStatus.done);
    });
  });

  group('sortByStack', () {
    test('empty / single-element list is returned unchanged', () {
      expect(sortByStack(const []), isEmpty);
      final one = [_stackHabit(id: 'a', name: 'A')];
      expect(sortByStack(one).map((h) => h.id), ['a']);
    });

    test('A → B chain places follower right after anchor', () {
      // Input order: B (depends on A), A.
      final habits = [
        _stackHabit(id: 'b', name: 'B', stackAfter: 'a'),
        _stackHabit(id: 'a', name: 'A'),
      ];
      final sorted = sortByStack(habits);
      expect(sorted.map((h) => h.id).toList(), ['a', 'b']);
    });

    test('A → B → C chain resolves recursively', () {
      final habits = [
        _stackHabit(id: 'c', name: 'C', stackAfter: 'b'),
        _stackHabit(id: 'b', name: 'B', stackAfter: 'a'),
        _stackHabit(id: 'a', name: 'A'),
      ];
      final sorted = sortByStack(habits);
      expect(sorted.map((h) => h.id).toList(), ['a', 'b', 'c']);
    });

    test('multiple followers of the same anchor keep input order', () {
      final habits = [
        _stackHabit(id: 'a', name: 'A'),
        _stackHabit(id: 'b1', name: 'B1', stackAfter: 'a'),
        _stackHabit(id: 'b2', name: 'B2', stackAfter: 'a'),
      ];
      final sorted = sortByStack(habits);
      expect(sorted.map((h) => h.id).toList(), ['a', 'b1', 'b2']);
    });

    test('follower with unknown anchor falls back to original position', () {
      final habits = [
        _stackHabit(id: 'a', name: 'A'),
        _stackHabit(id: 'orphan', name: 'Orphan', stackAfter: 'missing'),
        _stackHabit(id: 'c', name: 'C'),
      ];
      final sorted = sortByStack(habits);
      expect(sorted.map((h) => h.id).toList(), ['a', 'orphan', 'c']);
    });

    test('cycle does not lose habits', () {
      // a → b, b → a (cycle). Both should still appear.
      final habits = [
        _stackHabit(id: 'a', name: 'A', stackAfter: 'b'),
        _stackHabit(id: 'b', name: 'B', stackAfter: 'a'),
      ];
      final sorted = sortByStack(habits);
      expect(sorted.length, 2);
      expect(sorted.map((h) => h.id).toSet(), {'a', 'b'});
    });
  });
}
