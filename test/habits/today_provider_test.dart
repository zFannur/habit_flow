import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/habits/data/habit_log_model.dart';
import 'package:habit_flow/features/habits/data/habit_model.dart';
import 'package:habit_flow/features/habits/data/habits_providers.dart';
import 'package:habit_flow/features/habits/domain/habit_calculations.dart';
import 'package:habit_flow/features/habits/domain/habit_log_status.dart';
import 'package:habit_flow/features/habits/domain/habit_type.dart';
import 'package:habit_flow/features/habits/domain/schedule_type.dart';

HabitModel _habit({
  String id = 'h1',
  ScheduleType scheduleType = ScheduleType.daily,
  Map<String, dynamic> schedule = const <String, dynamic>{},
  DateTime? startedAt,
}) {
  final start = startedAt ?? DateTime(2026, 1, 1);
  return HabitModel(
    id: id,
    userId: 'u1',
    name: 'Habit $id',
    type: HabitType.binary,
    scheduleType: scheduleType,
    schedule: schedule,
    startedAt: start,
    createdAt: start,
    updatedAt: start,
  );
}

HabitLogModel _log({
  required String habitId,
  required DateTime date,
  HabitLogStatus status = HabitLogStatus.done,
}) {
  return HabitLogModel(
    id: 'log-$habitId-${date.toIso8601String()}',
    userId: 'u1',
    habitId: habitId,
    date: date,
    status: status,
    createdAt: date,
  );
}

void main() {
  group('combineHabitsWithLogs', () {
    final today = DateTime(2026, 5, 7); // Thursday

    test('habits without logs return null log slot', () {
      final habits = [_habit(id: 'a'), _habit(id: 'b')];
      final out = combineHabitsWithLogs(
        habits: habits,
        logsForDay: const [],
        day: today,
      );
      expect(out, hasLength(2));
      expect(out[0].log, isNull);
      expect(out[1].log, isNull);
      expect(out[0].isLogged, isFalse);
    });

    test('matches log to habit by id', () {
      final habits = [_habit(id: 'a'), _habit(id: 'b')];
      final logs = [
        _log(habitId: 'a', date: today, status: HabitLogStatus.done),
      ];
      final out = combineHabitsWithLogs(
        habits: habits,
        logsForDay: logs,
        day: today,
      );
      final byId = {for (final hwl in out) hwl.habit.id: hwl};
      expect(byId['a']!.log, isNotNull);
      expect(byId['a']!.isDone, isTrue);
      expect(byId['b']!.log, isNull);
    });

    test('filters out habits not scheduled for the day', () {
      // Habit only on Mondays; today is Thursday.
      final mondayOnly = _habit(
        id: 'mon',
        scheduleType: ScheduleType.weekdays,
        schedule: {'weekdays': [1]},
      );
      final daily = _habit(id: 'daily');
      final out = combineHabitsWithLogs(
        habits: [mondayOnly, daily],
        logsForDay: const [],
        day: today,
      );
      expect(out, hasLength(1));
      expect(out.single.habit.id, 'daily');
    });

    test('ignores logs whose date is not today', () {
      final habits = [_habit(id: 'a')];
      final logs = [
        _log(habitId: 'a', date: DateTime(2026, 5, 6)),
      ];
      final out = combineHabitsWithLogs(
        habits: habits,
        logsForDay: logs,
        day: today,
      );
      expect(out.single.log, isNull);
    });

    test('preserves order from habits list', () {
      final habits = [
        _habit(id: 'first'),
        _habit(id: 'second'),
        _habit(id: 'third'),
      ];
      final out = combineHabitsWithLogs(
        habits: habits,
        logsForDay: const [],
        day: today,
      );
      expect(out.map((h) => h.habit.id).toList(), ['first', 'second', 'third']);
    });
  });

  group('habitDetailProvider', () {
    test('returns habit when id present in habits stream', () async {
      final today = DateTime(2026, 5, 7);
      final habit = _habit(id: 'target');
      final container = ProviderContainer(
        overrides: [
          todayProvider.overrideWithValue(today),
          habitsStreamProvider.overrideWith((ref) => Stream.value([habit])),
        ],
      );
      addTearDown(container.dispose);

      // Wait for stream to emit.
      await container.read(habitsStreamProvider.future);

      final result = container.read(habitDetailProvider('target'));
      expect(result.value?.id, 'target');
    });

    test('returns null when id is unknown', () async {
      final today = DateTime(2026, 5, 7);
      final habit = _habit(id: 'h1');
      final container = ProviderContainer(
        overrides: [
          todayProvider.overrideWithValue(today),
          habitsStreamProvider.overrideWith((ref) => Stream.value([habit])),
        ],
      );
      addTearDown(container.dispose);
      await container.read(habitsStreamProvider.future);

      final result = container.read(habitDetailProvider('missing'));
      expect(result.value, isNull);
    });
  });

  group('streakProvider', () {
    test('returns 0 when habits or logs not yet loaded', () {
      // No overrides on logs → still loading; stream provider would normally
      // hit Supabase. We override habits to AsyncLoading by leaving the stream
      // pending (uncompleted).
      final container = ProviderContainer(
        overrides: [
          todayProvider.overrideWithValue(DateTime(2026, 5, 7)),
          habitsStreamProvider.overrideWith(
            (ref) => const Stream<List<HabitModel>>.empty(),
          ),
          habitLogsForHabitProvider.overrideWith(
            (ref, _) => const Stream<List<HabitLogModel>>.empty(),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Both async values are loading → streak = 0.
      expect(container.read(streakProvider('h1')), 0);
    });

    test('computes streak from logs and habit', () async {
      final today = DateTime(2026, 5, 7);
      final habit = _habit(id: 'h1');
      final logs = [
        _log(habitId: 'h1', date: DateTime(2026, 5, 7)),
        _log(habitId: 'h1', date: DateTime(2026, 5, 6)),
        _log(habitId: 'h1', date: DateTime(2026, 5, 5)),
      ];

      final container = ProviderContainer(
        overrides: [
          todayProvider.overrideWithValue(today),
          habitsStreamProvider.overrideWith((ref) => Stream.value([habit])),
          habitLogsForHabitProvider.overrideWith(
            (ref, habitId) => Stream.value(logs),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(habitsStreamProvider.future);
      await container.read(habitLogsForHabitProvider('h1').future);

      expect(container.read(streakProvider('h1')), 3);
    });
  });

  group('habitHeatmapProvider', () {
    test('builds map from logs stream', () async {
      final today = DateTime(2026, 5, 7);
      final logs = [
        _log(habitId: 'h1', date: DateTime(2026, 5, 7)),
        _log(habitId: 'h1', date: DateTime(2026, 5, 6),
            status: HabitLogStatus.partial),
      ];
      final container = ProviderContainer(
        overrides: [
          todayProvider.overrideWithValue(today),
          habitLogsForHabitProvider.overrideWith(
            (ref, _) => Stream.value(logs),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(habitLogsForHabitProvider('h1').future);

      final result = container.read(
        habitHeatmapProvider((habitId: 'h1', daysBack: 7)),
      );
      expect(result.value?[DateTime(2026, 5, 7)], HabitLogStatus.done);
      expect(result.value?[DateTime(2026, 5, 6)], HabitLogStatus.partial);
    });
  });
}
