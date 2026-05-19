import '../data/habit_log_model.dart';
import '../data/habit_model.dart';

/// Pairing of a habit with the log row (if any) for a single calendar day.
///
/// Used by `todayHabitsProvider` so the UI can render check / progress state
/// for each habit on Today tab without issuing per-habit lookups.
class HabitWithLog {
  const HabitWithLog({required this.habit, this.log});

  final HabitModel habit;
  final HabitLogModel? log;

  bool get isLogged => log != null;
  bool get isDone => log?.isDone ?? false;
  bool get isPartial => log?.isPartial ?? false;
  bool get isSkipped => log?.isSkipped ?? false;

  HabitWithLog copyWith({HabitModel? habit, HabitLogModel? log}) {
    return HabitWithLog(habit: habit ?? this.habit, log: log ?? this.log);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitWithLog && other.habit == habit && other.log == log);

  @override
  int get hashCode => Object.hash(habit, log);
}
