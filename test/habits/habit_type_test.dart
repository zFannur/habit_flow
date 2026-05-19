import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/habits/domain/habit_log_status.dart';
import 'package:habit_flow/features/habits/domain/habit_status.dart';
import 'package:habit_flow/features/habits/domain/habit_type.dart';
import 'package:habit_flow/features/habits/domain/schedule_type.dart';

void main() {
  group('HabitType.fromString', () {
    test('decodes every wire value', () {
      expect(HabitType.fromString('binary'), HabitType.binary);
      expect(HabitType.fromString('countable'), HabitType.countable);
      expect(HabitType.fromString('timed'), HabitType.timed);
      expect(HabitType.fromString('anti'), HabitType.anti);
    });

    test('throws ArgumentError on unknown value', () {
      expect(() => HabitType.fromString('weird'), throwsArgumentError);
      expect(() => HabitType.fromString(''), throwsArgumentError);
    });

    test('round-trip wireName <-> fromString is stable', () {
      for (final t in HabitType.values) {
        expect(HabitType.fromString(t.wireName), t);
      }
    });
  });

  group('HabitStatus.fromString', () {
    test('decodes every wire value', () {
      expect(HabitStatus.fromString('active'), HabitStatus.active);
      expect(HabitStatus.fromString('paused'), HabitStatus.paused);
      expect(HabitStatus.fromString('archived'), HabitStatus.archived);
    });

    test('throws on unknown value', () {
      expect(() => HabitStatus.fromString('deleted'), throwsArgumentError);
    });
  });

  group('HabitLogStatus.fromString', () {
    test('decodes every wire value', () {
      expect(HabitLogStatus.fromString('done'), HabitLogStatus.done);
      expect(HabitLogStatus.fromString('partial'), HabitLogStatus.partial);
      expect(HabitLogStatus.fromString('skipped'), HabitLogStatus.skipped);
      expect(HabitLogStatus.fromString('missed'), HabitLogStatus.missed);
    });

    test('throws on unknown value', () {
      expect(() => HabitLogStatus.fromString('completed'), throwsArgumentError);
    });
  });

  group('ScheduleType.fromString', () {
    test('decodes every wire value', () {
      expect(ScheduleType.fromString('daily'), ScheduleType.daily);
      expect(ScheduleType.fromString('weekdays'), ScheduleType.weekdays);
      expect(ScheduleType.fromString('n_per_week'), ScheduleType.nPerWeek);
      expect(ScheduleType.fromString('every_n_days'), ScheduleType.everyNDays);
      expect(
        ScheduleType.fromString('monthly_dates'),
        ScheduleType.monthlyDates,
      );
    });

    test('throws on unknown value', () {
      expect(() => ScheduleType.fromString('hourly'), throwsArgumentError);
    });
  });
}
