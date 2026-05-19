/// Cadence of a habit. Mirrors the Postgres `schedule_type` enum (SPEC §5).
enum ScheduleType {
  daily('daily'),
  weekdays('weekdays'),
  nPerWeek('n_per_week'),
  everyNDays('every_n_days'),
  monthlyDates('monthly_dates');

  const ScheduleType(this.wireName);

  final String wireName;

  static ScheduleType fromString(String value) {
    for (final s in ScheduleType.values) {
      if (s.wireName == value) return s;
    }
    throw ArgumentError.value(value, 'value', 'Unknown ScheduleType');
  }
}
