/// Inclusive calendar-day range used by analytics aggregations.
///
/// Both [from] and [to] are interpreted as date-only values — the time of day
/// is ignored by aggregation helpers. [from] must be `<= to`.
class DateRange {
  const DateRange({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  /// Number of calendar days in the range, inclusive.
  ///
  /// Returns 0 when [to] is before [from].
  int get days {
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    if (t.isBefore(f)) return 0;
    return t.difference(f).inDays + 1;
  }

  /// Whether [date]'s calendar day falls inside this range (inclusive).
  bool contains(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return !d.isBefore(f) && !d.isAfter(t);
  }

  /// ISO week (Mon..Sun) that contains [day]. Useful for `weeklyStatsProvider`.
  factory DateRange.weekOf(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    // weekday: Mon=1..Sun=7. Subtract (weekday-1) days to land on Monday.
    final monday = d.subtract(Duration(days: d.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return DateRange(from: monday, to: sunday);
  }

  /// Calendar month containing [day].
  factory DateRange.monthOf(DateTime day) {
    final first = DateTime(day.year, day.month, 1);
    // Day 0 of the next month == last day of this month.
    final last = DateTime(day.year, day.month + 1, 0);
    return DateRange(from: first, to: last);
  }
}
