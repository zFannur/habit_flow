/// Lifecycle status of a habit.
///
/// Note: the DB stores this as the boolean `is_archived` plus optional
/// `end_date` (SPEC §5). [HabitStatus] is a derived, app-side projection that
/// makes UI branching ergonomic.
enum HabitStatus {
  active('active'),
  paused('paused'),
  archived('archived');

  const HabitStatus(this.wireName);

  final String wireName;

  static HabitStatus fromString(String value) {
    for (final s in HabitStatus.values) {
      if (s.wireName == value) return s;
    }
    throw ArgumentError.value(value, 'value', 'Unknown HabitStatus');
  }
}
