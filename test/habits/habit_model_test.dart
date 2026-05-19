import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/habits/data/habit_category_model.dart';
import 'package:habit_flow/features/habits/data/habit_log_model.dart';
import 'package:habit_flow/features/habits/data/habit_model.dart';
import 'package:habit_flow/features/habits/domain/habit_log_status.dart';
import 'package:habit_flow/features/habits/domain/habit_status.dart';
import 'package:habit_flow/features/habits/domain/habit_type.dart';
import 'package:habit_flow/features/habits/domain/schedule_type.dart';

Map<String, dynamic> _habitJson() => <String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'user_id': '22222222-2222-2222-2222-222222222222',
      'name': 'Drink water',
      'category': 'health',
      'category_id': '33333333-3333-3333-3333-333333333333',
      'habit_type': 'countable',
      'icon_emoji': '💧',
      'icon_telegram_file_id': null,
      'color': '#3B82F6',
      'target_value': 8,
      'target_unit': 'cups',
      'schedule_type': 'weekdays',
      'schedule_config': {'weekdays': [1, 2, 3, 4, 5]},
      'reminder_times': ['08:00:00', '14:00:00'],
      'start_date': '2026-01-01',
      'end_date': null,
      'stack_after_habit_id': null,
      'implementation_when': 'After breakfast',
      'implementation_where': 'Kitchen',
      'identity_statement': 'I am hydrated',
      'two_minute_version': 'Drink one cup',
      'reward': 'Tea',
      'is_archived': false,
      'position': 0,
      'created_at': '2026-01-01T08:00:00.000Z',
      'updated_at': '2026-01-02T09:30:00.000Z',
    };

Map<String, dynamic> _logJson() => <String, dynamic>{
      'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'user_id': '22222222-2222-2222-2222-222222222222',
      'habit_id': '11111111-1111-1111-1111-111111111111',
      'log_date': '2026-05-07',
      'status': 'done',
      'value': 8,
      'comment': 'Easy day',
      'created_at': '2026-05-07T20:15:00.000Z',
    };

Map<String, dynamic> _categoryJson() => <String, dynamic>{
      'id': '33333333-3333-3333-3333-333333333333',
      'user_id': null,
      'name': 'Health',
      'icon_emoji': '🩺',
      'created_at': '2026-01-01T00:00:00.000Z',
    };

void main() {
  group('HabitModel JSON', () {
    test('round-trip JSON -> model -> JSON is stable', () {
      final jsonIn = _habitJson();
      final model = HabitModel.fromJson(jsonIn);
      final jsonOut = model.toJson();

      expect(jsonOut['id'], jsonIn['id']);
      expect(jsonOut['user_id'], jsonIn['user_id']);
      expect(jsonOut['habit_type'], 'countable');
      expect(jsonOut['schedule_type'], 'weekdays');
      expect(jsonOut['schedule_config'], jsonIn['schedule_config']);
      expect(jsonOut['reminder_times'], ['08:00:00', '14:00:00']);
      expect(jsonOut['start_date'], '2026-01-01');
      expect(jsonOut['end_date'], null);
      expect(jsonOut['target_value'], 8);
      expect(jsonOut['icon_emoji'], '💧');

      // Re-decode the produced JSON — should yield an equal model.
      final model2 = HabitModel.fromJson(jsonOut);
      expect(model2, model);
    });

    test('parses enums via custom converters', () {
      final m = HabitModel.fromJson(_habitJson());
      expect(m.type, HabitType.countable);
      expect(m.scheduleType, ScheduleType.weekdays);
    });

    test('computed type getters', () {
      final base = HabitModel.fromJson(_habitJson());
      expect(base.isCountable, true);
      expect(base.isBinary, false);
      expect(base.isTimed, false);
      expect(base.isAnti, false);

      final anti = base.copyWith(type: HabitType.anti);
      expect(anti.isAnti, true);
      expect(anti.isCountable, false);
    });

    test('status derives from is_archived / end_date', () {
      final active = HabitModel.fromJson(_habitJson());
      expect(active.status, HabitStatus.active);

      final archived = active.copyWith(isArchived: true);
      expect(archived.status, HabitStatus.archived);

      final paused = active.copyWith(
        endedAt: DateTime.utc(2020, 1, 1),
      );
      expect(paused.status, HabitStatus.paused);
    });

    group('isToday', () {
      final base = HabitModel.fromJson(_habitJson());

      test('weekdays cadence respects schedule_config.weekdays', () {
        // 2026-05-07 is Thursday (weekday 4) — included.
        expect(base.isToday(DateTime(2026, 5, 7)), true);
        // 2026-05-09 is Saturday (weekday 6) — not included.
        expect(base.isToday(DateTime(2026, 5, 9)), false);
      });

      test('returns false before startedAt', () {
        expect(base.isToday(DateTime(2025, 12, 31)), false);
      });

      test('returns false when archived', () {
        final archived = base.copyWith(isArchived: true);
        expect(archived.isToday(DateTime(2026, 5, 7)), false);
      });

      test('daily cadence selects every day', () {
        final daily = base.copyWith(
          scheduleType: ScheduleType.daily,
          schedule: const {},
        );
        expect(daily.isToday(DateTime(2026, 5, 7)), true);
        expect(daily.isToday(DateTime(2026, 5, 9)), true);
      });

      test('every_n_days cadence respects every_n', () {
        final every3 = base.copyWith(
          scheduleType: ScheduleType.everyNDays,
          schedule: const {'every_n': 3},
          // start_date is 2026-01-01 (Thursday).
        );
        // 2026-01-01: diff 0 -> match.
        expect(every3.isToday(DateTime(2026, 1, 1)), true);
        // 2026-01-02: diff 1 -> no.
        expect(every3.isToday(DateTime(2026, 1, 2)), false);
        // 2026-01-04: diff 3 -> match.
        expect(every3.isToday(DateTime(2026, 1, 4)), true);
      });

      test('monthly_dates cadence respects dates', () {
        final monthly = base.copyWith(
          scheduleType: ScheduleType.monthlyDates,
          schedule: const {'dates': [1, 15]},
        );
        expect(monthly.isToday(DateTime(2026, 5, 1)), true);
        expect(monthly.isToday(DateTime(2026, 5, 15)), true);
        expect(monthly.isToday(DateTime(2026, 5, 7)), false);
      });
    });
  });

  group('HabitLogModel JSON', () {
    test('round-trip JSON -> model -> JSON', () {
      final jsonIn = _logJson();
      final model = HabitLogModel.fromJson(jsonIn);
      final jsonOut = model.toJson();

      expect(jsonOut['id'], jsonIn['id']);
      expect(jsonOut['habit_id'], jsonIn['habit_id']);
      expect(jsonOut['log_date'], '2026-05-07');
      expect(jsonOut['status'], 'done');
      expect(jsonOut['value'], 8);
      expect(jsonOut['comment'], 'Easy day');

      final model2 = HabitLogModel.fromJson(jsonOut);
      expect(model2, model);
    });

    test('status getters', () {
      final done = HabitLogModel.fromJson(_logJson());
      expect(done.isDone, true);
      expect(done.isMissed, false);

      final missed = done.copyWith(status: HabitLogStatus.missed);
      expect(missed.isMissed, true);
      expect(missed.isDone, false);
    });

    test('isOnDay compares only Y/M/D', () {
      final log = HabitLogModel.fromJson(_logJson());
      expect(log.isOnDay(DateTime(2026, 5, 7, 23, 59)), true);
      expect(log.isOnDay(DateTime(2026, 5, 8)), false);
    });
  });

  group('HabitCategoryModel JSON', () {
    test('round-trip', () {
      final jsonIn = _categoryJson();
      final model = HabitCategoryModel.fromJson(jsonIn);
      final jsonOut = model.toJson();

      expect(jsonOut['id'], jsonIn['id']);
      expect(jsonOut['user_id'], null);
      expect(jsonOut['name'], 'Health');
      expect(jsonOut['icon_emoji'], '🩺');

      expect(HabitCategoryModel.fromJson(jsonOut), model);
    });

    test('isSystem when user_id is null', () {
      final system = HabitCategoryModel.fromJson(_categoryJson());
      expect(system.isSystem, true);

      final user = system.copyWith(userId: 'u1');
      expect(user.isSystem, false);
    });
  });
}
