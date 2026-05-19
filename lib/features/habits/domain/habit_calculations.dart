import '../data/habit_log_model.dart';
import '../data/habit_model.dart';
import 'habit_log_status.dart';
import 'habit_with_log.dart';

/// Pure helpers used by Riverpod providers and widgets. Kept free of any
/// Supabase / Riverpod imports so they can be unit-tested directly.

/// Strips time-of-day from [d] so calendar-day comparisons (`isAtSameMomentAs`,
/// map keys, equality) work as expected.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Current streak of consecutive scheduled days ending at [today] for [habit].
///
/// Walk backwards from [today]. For each calendar day where the habit is
/// scheduled (`HabitModel.isToday`):
///   * `done` / `partial` → counts as streak day, continue walking.
///   * `skipped`          → does not increment, but does not break streak.
///   * `missed` or absent → streak ends.
///
/// Days the habit was not scheduled are simply skipped without breaking the
/// streak. The walk stops at the habit's `startedAt` to avoid infinite loops
/// for never-logged habits.
int currentStreak({
  required HabitModel habit,
  required List<HabitLogModel> logs,
  required DateTime today,
}) {
  if (logs.isEmpty && !habit.isToday(today)) return 0;

  // Index logs by date for O(1) lookup.
  final byDate = <DateTime, HabitLogModel>{};
  for (final log in logs) {
    byDate[dateOnly(log.date)] = log;
  }

  final start = dateOnly(habit.startedAt);
  var cursor = dateOnly(today);
  var streak = 0;

  // Hard cap so a malformed habit (e.g. far-past start) cannot loop forever.
  const maxDays = 3650;
  var iterations = 0;

  while (!cursor.isBefore(start) && iterations < maxDays) {
    iterations++;
    if (!habit.isToday(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      continue;
    }
    final log = byDate[cursor];
    if (log == null) {
      // Unscheduled day already handled; an absent log on a scheduled day
      // means missed → break streak. Exception: if the cursor is "today" and
      // the user simply has not logged yet, do NOT break — start counting
      // from the previous day instead.
      if (cursor == dateOnly(today)) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      break;
    }
    switch (log.status) {
      case HabitLogStatus.done:
      case HabitLogStatus.partial:
        streak++;
      case HabitLogStatus.skipped:
        // Skipped (vacation, sick day) keeps the streak alive but does not
        // count as a successful day.
        break;
      case HabitLogStatus.missed:
        return streak;
    }
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return streak;
}

/// Builds a `date → status` map covering [daysBack] calendar days ending at
/// [today]. Days without logs are simply absent from the map; the heatmap
/// widget treats absence as "no log" (distinct from `missed`).
Map<DateTime, HabitLogStatus> buildHeatmap({
  required List<HabitLogModel> logs,
  required DateTime today,
  required int daysBack,
}) {
  final cutoff = dateOnly(today).subtract(Duration(days: daysBack - 1));
  final result = <DateTime, HabitLogStatus>{};
  for (final log in logs) {
    final d = dateOnly(log.date);
    if (d.isBefore(cutoff) || d.isAfter(dateOnly(today))) continue;
    // If duplicates appear (shouldn't, since (habit_id,log_date) is unique),
    // last write wins — repository orders newest first so first write is the
    // canonical one.
    result.putIfAbsent(d, () => log.status);
  }
  return result;
}

/// Reorders [habits] so that any habit with a non-null `stackAfterHabitId`
/// is placed immediately after its anchor (SPEC §8 — Habit Stacking).
///
/// Rules:
///   * Anchors keep their relative order from the input list.
///   * Followers are inserted directly after their anchor; if multiple
///     followers share the same anchor, they keep their relative order.
///   * A → B → C chains resolve recursively: B placed after A, then C
///     placed after B.
///   * Followers whose `stackAfterHabitId` references an unknown id (or
///     is the habit itself) fall back to their original position so we
///     never silently drop habits.
///
/// The function never mutates the input list; it returns a new list of
/// the same length.
List<HabitModel> sortByStack(List<HabitModel> habits) {
  if (habits.length < 2) return List<HabitModel>.from(habits);

  final byId = <String, HabitModel>{for (final h in habits) h.id: h};

  // Identify which habits act as anchors that exist in this set. Followers
  // pointing to unknown anchors or to themselves are treated as anchors
  // for layout purposes (sit at their original position).
  bool isFollower(HabitModel h) {
    final anchor = h.stackAfterHabitId;
    if (anchor == null || anchor.isEmpty) return false;
    if (anchor == h.id) return false;
    return byId.containsKey(anchor);
  }

  // Group followers by anchor id, preserving original order.
  final followersByAnchor = <String, List<HabitModel>>{};
  for (final h in habits) {
    if (!isFollower(h)) continue;
    followersByAnchor.putIfAbsent(h.stackAfterHabitId!, () => []).add(h);
  }

  final result = <HabitModel>[];
  final emitted = <String>{};

  void emit(HabitModel h) {
    if (emitted.add(h.id)) {
      result.add(h);
      // Recursively emit followers right after this habit.
      final children = followersByAnchor[h.id];
      if (children != null) {
        for (final c in children) {
          emit(c);
        }
      }
    }
  }

  for (final h in habits) {
    if (isFollower(h)) continue;
    emit(h);
  }

  // Followers whose anchor was never emitted (cycle / dangling) — append
  // in original order so we never lose habits.
  for (final h in habits) {
    if (emitted.contains(h.id)) continue;
    emit(h);
  }

  return result;
}

/// Combines all active habits scheduled for [day] with the log for [day]
/// (if any). Habits that are not scheduled for [day] are filtered out.
List<HabitWithLog> combineHabitsWithLogs({
  required List<HabitModel> habits,
  required List<HabitLogModel> logsForDay,
  required DateTime day,
}) {
  final logsByHabit = <String, HabitLogModel>{};
  final target = dateOnly(day);
  for (final log in logsForDay) {
    if (dateOnly(log.date) != target) continue;
    logsByHabit[log.habitId] = log;
  }
  return [
    for (final h in habits)
      if (h.isToday(day))
        HabitWithLog(habit: h, log: logsByHabit[h.id]),
  ];
}
