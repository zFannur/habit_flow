/// Status of a single [HabitLogModel] entry. Mirrors the Postgres
/// `log_status` enum (SPEC §5).
enum HabitLogStatus {
  done('done'),
  partial('partial'),
  skipped('skipped'),
  missed('missed');

  const HabitLogStatus(this.wireName);

  final String wireName;

  static HabitLogStatus fromString(String value) {
    for (final s in HabitLogStatus.values) {
      if (s.wireName == value) return s;
    }
    throw ArgumentError.value(value, 'value', 'Unknown HabitLogStatus');
  }
}
