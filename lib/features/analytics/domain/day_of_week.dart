/// ISO weekday: Monday..Sunday. Mirrors `DateTime.weekday` (1..7).
enum DayOfWeek {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const DayOfWeek(this.iso);

  /// 1..7 to match `DateTime.weekday`.
  final int iso;

  static DayOfWeek fromDateTime(DateTime d) {
    switch (d.weekday) {
      case DateTime.monday:
        return DayOfWeek.monday;
      case DateTime.tuesday:
        return DayOfWeek.tuesday;
      case DateTime.wednesday:
        return DayOfWeek.wednesday;
      case DateTime.thursday:
        return DayOfWeek.thursday;
      case DateTime.friday:
        return DayOfWeek.friday;
      case DateTime.saturday:
        return DayOfWeek.saturday;
      case DateTime.sunday:
      default:
        return DayOfWeek.sunday;
    }
  }
}
