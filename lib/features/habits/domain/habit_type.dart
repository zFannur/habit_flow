/// Type of habit, mirrors `habit_type` Postgres enum (SPEC §5).
enum HabitType {
  /// Done / not done — single tap.
  binary('binary'),

  /// Counts up to a target value (e.g. 8 cups, 20 pages).
  countable('countable'),

  /// Tracks elapsed time (timer / minutes).
  timed('timed'),

  /// Negative habit — counts streak of avoidance.
  anti('anti');

  const HabitType(this.wireName);

  /// Value as stored in the DB and JSON payloads.
  final String wireName;

  /// Decode from DB / JSON. Throws [ArgumentError] on unknown values so that
  /// schema drift is surfaced loudly instead of silently coerced.
  static HabitType fromString(String value) {
    for (final t in HabitType.values) {
      if (t.wireName == value) return t;
    }
    throw ArgumentError.value(value, 'value', 'Unknown HabitType');
  }
}
