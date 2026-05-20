import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journal/data/journal_providers.dart'
    show supabaseClientProvider, currentUserIdProvider;
import '../domain/habit_calculations.dart';
import '../domain/habit_log_status.dart';
import '../domain/habit_with_log.dart';
import 'habit_log_model.dart';
import 'habit_logs_repository.dart';
import 'habit_model.dart';
import 'habits_repository.dart';

// Re-export the shared providers so habits feature does not need to import
// from journal/ directly.
export '../../journal/data/journal_providers.dart'
    show supabaseClientProvider, currentUserIdProvider;

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return HabitsRepository(
    client: ref.watch(supabaseClientProvider),
    userId: ref.watch(currentUserIdProvider),
  );
});

final habitLogsRepositoryProvider = Provider<HabitLogsRepository>((ref) {
  return HabitLogsRepository(
    client: ref.watch(supabaseClientProvider),
    userId: ref.watch(currentUserIdProvider),
  );
});

/// Realtime list of habits for the current user.
final habitsStreamProvider = StreamProvider<List<HabitModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(habitsRepositoryProvider).watchAll(userId).map((habits) {
    final seen = <String>{};
    return habits.where((h) => seen.add(h.id)).toList();
  });
});

/// Logs for a single habit (newest first).
final habitLogsForHabitProvider =
    StreamProvider.family<List<HabitLogModel>, String>((ref, habitId) {
  return ref.watch(habitLogsRepositoryProvider).watchForHabit(habitId);
});

/// Today's date with time stripped — overridable in tests so that
/// [todayHabitsProvider], [streakProvider] and [habitHeatmapProvider] are
/// deterministic without monkey-patching `DateTime.now`.
final todayProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Logs for the current user on [todayProvider]'s date. Refetches each time
/// `habitsStreamProvider` emits, so a freshly-created habit is paired with
/// its (still empty) log slot immediately. Public so `today_screen` can
/// invalidate it after a `log()` call — `habit_logs` is a separate table and
/// changes to it do not propagate through `habitsStreamProvider`.
final todayLogsProvider = FutureProvider<List<HabitLogModel>>((ref) async {
  final today = ref.watch(todayProvider);
  ref.watch(habitsStreamProvider);
  return ref.watch(habitLogsRepositoryProvider).rangeForUser(today, today);
});

/// Habits scheduled for today paired with the log row for today (if any).
///
/// Treats provider errors as **soft**: if logs fetch failed but habits
/// arrived, the screen still renders the list with empty log slots; if
/// habits stream itself errored we surface an empty list (UI shows
/// empty-state, not a red error widget). Real errors are still emitted
/// by the underlying providers and visible in DevTools.
final todayHabitsProvider = Provider<AsyncValue<List<HabitWithLog>>>((ref) {
  final today = ref.watch(todayProvider);
  final habitsAsync = ref.watch(habitsStreamProvider);
  final logsAsync = ref.watch(todayLogsProvider);

  // Both still loading → show skeleton.
  if (habitsAsync.isLoading && logsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final habits = habitsAsync.value ?? const <HabitModel>[];
  final logs = logsAsync.value ?? const <HabitLogModel>[];

  final combined = combineHabitsWithLogs(
    habits: habits,
    logsForDay: logs,
    day: today,
  );
  // Deduplicate — insurance against overlapping realtime + invalidate events.
  final seen = <String>{};
  final deduped = combined.where((h) => seen.add(h.habit.id)).toList();
  return AsyncValue.data(deduped);
});

/// Single-habit lookup used by the detail screen. Falls back to [null] when
/// the id is unknown — the screen can then show a "not found" state instead
/// of throwing.
final habitDetailProvider =
    Provider.family<AsyncValue<HabitModel?>, String>((ref, id) {
  final habitsAsync = ref.watch(habitsStreamProvider);
  return habitsAsync.whenData((list) {
    for (final h in list) {
      if (h.id == id) return h;
    }
    return null;
  });
});

/// `date → status` heatmap for [habitId] over the last [daysBack] days.
final habitHeatmapProvider = Provider.family<
    AsyncValue<Map<DateTime, HabitLogStatus>>,
    ({String habitId, int daysBack})>((ref, args) {
  final today = ref.watch(todayProvider);
  final logsAsync = ref.watch(habitLogsForHabitProvider(args.habitId));
  return logsAsync.whenData(
    (logs) => buildHeatmap(
      logs: logs,
      today: today,
      daysBack: args.daysBack,
    ),
  );
});

/// Current consecutive-day streak for [habitId]. Returns `0` while either
/// the habits list or the logs stream is still loading or in error.
final streakProvider = Provider.family<int, String>((ref, habitId) {
  final today = ref.watch(todayProvider);
  final habitAsync = ref.watch(habitDetailProvider(habitId));
  final logsAsync = ref.watch(habitLogsForHabitProvider(habitId));
  final habit = habitAsync.value;
  final logs = logsAsync.value;
  if (habit == null || logs == null) return 0;
  return currentStreak(habit: habit, logs: logs, today: today);
});
