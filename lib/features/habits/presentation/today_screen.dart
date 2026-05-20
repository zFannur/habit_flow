import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_button.dart';
import '../../../shared/widgets/hf_empty_state.dart';
import '../../../shared/widgets/hf_skeleton.dart';
import '../../journal/data/journal_providers.dart';
import '../data/habit_model.dart';
import '../data/habits_providers.dart';
import '../domain/habit_log_status.dart';
import '../domain/habit_type.dart';
import '../domain/habit_with_log.dart';
import 'widgets/all_done_celebration.dart';
import 'widgets/anti_habit_card.dart';
import 'widgets/binary_habit_card.dart';
import 'widgets/countable_habit_card.dart';
import 'widgets/journal_today_card.dart';
import 'widgets/timed_habit_card.dart';

/// Tab 1: Сегодня (см. today-screen.html).
/// Header (дата, сводка, аватар) + список карточек привычек +
/// карточка дневника + ghost-кнопка "Добавить привычку".
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _wasAllDone = false;
  bool _showCelebration = false;

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(todayHabitsProvider);

    ref.listen<AsyncValue<List<HabitWithLog>>>(todayHabitsProvider, (_, next) {
      next.whenData((habits) {
        if (habits.isEmpty) {
          _wasAllDone = false;
          return;
        }
        final allDone = habits.every((h) => h.isDone);
        if (allDone && !_wasAllDone) {
          setState(() => _showCelebration = true);
        }
        _wasAllDone = allDone;
      });
    });

    return Stack(
      children: [
        Column(
          children: [
            _TodayHeader(habitsAsync: habitsAsync),
            Expanded(
              // Fail-soft: a stream error in habits / today logs (expired
              // session, RLS hiccup) used to paint a full-screen red box.
              // Render an empty list so the header, ghost-add button and
              // empty-state CTA stay reachable.
              child: habitsAsync.when(
                loading: () => const _TodaySkeletonList(),
                error: (e, st) {
                  debugPrint('todayHabitsProvider error: $e\n$st');
                  return _HabitsList(habits: const [], ref: ref);
                },
                data: (habits) => _HabitsList(habits: habits, ref: ref),
              ),
            ),
          ],
        ),
        if (_showCelebration)
          AllDoneCelebration(
            onDismiss: () => setState(() => _showCelebration = false),
          ),
      ],
    );
  }
}

class _HabitsList extends ConsumerWidget {
  const _HabitsList({required this.habits, required this.ref});

  final List<HabitWithLog> habits;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final hasTodayEntry = ref.watch(journalTodayEntryProvider) != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      children: [
        _SectionTitle(text: l.navToday, color: c.textPrimary),
        const SizedBox(height: 14),
        if (habits.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: HFEmptyState(
              emoji: '🌱',
              title: l.emptyTitleNoHabits,
              description: l.emptyDescNoHabits,
              action: HFButton(
                label: l.todayAddHabit,
                onPressed: () => context.push('/habits/new'),
              ),
            ),
          ),
        for (final item in habits) ...[
          _HabitCardRouter(item: item, ref: ref),
          const SizedBox(height: HFTokens.s12),
        ],
        _GhostAdd(onTap: () => context.push('/habits/new')),
        if (!hasTodayEntry) ...[
          const SizedBox(height: 8),
          JournalTodayCard(onOpen: () => context.push('/journal/new')),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HabitCardRouter extends StatelessWidget {
  const _HabitCardRouter({required this.item, required this.ref});

  final HabitWithLog item;
  final WidgetRef ref;

  Future<void> _log(
    HabitLogStatus status, {
    num? value,
  }) async {
    final today = ref.read(todayProvider);
    await ref
        .read(habitLogsRepositoryProvider)
        .log(item.habit.id, today, status, value: value);
    // habit_logs is a separate table — habitsStreamProvider only re-emits
    // on `habits` changes. Force the day's logs to refetch so isDone, the
    // celebration listener and the streak read pick up the new state.
    ref.invalidate(todayLogsProvider);
    ref.invalidate(habitLogsForHabitProvider(item.habit.id));
  }

  @override
  Widget build(BuildContext context) {
    final habit = item.habit;
    final streak = ref.watch(streakProvider(habit.id));

    switch (habit.type) {
      case HabitType.binary:
        // 08-01: anchor lookup for "После: <emoji> <name>" sub-line.
        final anchor = _findAnchor(habit.stackAfterHabitId, ref);
        return BinaryHabitCard(
          emoji: habit.emoji ?? '✅',
          name: habit.name,
          subtitle: _reminderSubtitle(habit.reminderTimes),
          streak: streak > 0 ? streak : null,
          initialDone: item.isDone,
          stackAfterEmoji: anchor?.emoji,
          stackAfterName: anchor?.name,
          implementationWhen: habit.implementationWhen,
          implementationWhere: habit.implementationWhere,
          twoMinuteVersion: habit.twoMinuteVersion,
          onToggle: (done) => _log(
            done ? HabitLogStatus.done : HabitLogStatus.missed,
          ),
          onLog: (status) => _log(status),
        );

      case HabitType.countable:
        final target = (habit.target ?? 1).toInt();
        final current = (item.log?.value ?? 0).toInt();
        return CountableHabitCard(
          emoji: habit.emoji ?? '🔢',
          name: habit.name,
          initial: current,
          total: target,
          unit: habit.unit ?? '',
          onProgress: (value) => _log(
            value >= target ? HabitLogStatus.done : HabitLogStatus.partial,
            value: value,
          ),
        );

      case HabitType.timed:
        return TimedHabitCard(
          emoji: habit.emoji ?? '⏱',
          name: habit.name,
          subtitle: _reminderSubtitle(habit.reminderTimes),
          streak: streak > 0 ? streak : null,
          initialDone: item.isDone,
          onDone: (elapsedSeconds) => _log(
            HabitLogStatus.done,
            value: elapsedSeconds,
          ),
        );

      case HabitType.anti:
        return AntiHabitCard(
          emoji: habit.emoji ?? '🛡',
          name: habit.name,
          days: streak,
          initialHeld: item.isDone,
          onHeld: () => _log(HabitLogStatus.done),
        );
    }
  }

  String _reminderSubtitle(List<String> times) {
    if (times.isEmpty) return '';
    return times.first.substring(0, 5); // "HH:MM" from "HH:MM:SS"
  }

  /// Returns the anchor habit referenced by [anchorId], or `null` when the
  /// id is empty or the habit list is not loaded yet. Used to render the
  /// 08-01 stacking sub-line.
  HabitModel? _findAnchor(String? anchorId, WidgetRef ref) {
    if (anchorId == null || anchorId.isEmpty) return null;
    final list = ref.watch(habitsStreamProvider).valueOrNull;
    if (list == null) return null;
    for (final h in list) {
      if (h.id == anchorId) return h;
    }
    return null;
  }
}

class _TodayHeader extends ConsumerWidget {
  const _TodayHeader({required this.habitsAsync});

  final AsyncValue<List<HabitWithLog>> habitsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final now = ref.watch(todayProvider);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat('EEE, d MMMM', locale).format(now);

    final int done;
    final int total;
    final int maxStreak;

    switch (habitsAsync) {
      case AsyncData(:final value):
        done = value.where((h) => h.isDone).length;
        total = value.length;
        maxStreak = value.isEmpty
            ? 0
            : value
                .map((h) => ref.watch(streakProvider(h.habit.id)))
                .reduce((a, b) => a > b ? a : b);
      case _:
        done = 0;
        total = 0;
        maxStreak = 0;
    }

    return Container(
      decoration: BoxDecoration(
        color: c.bgSecondary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dateLabel,
                  style: context.tt.headlineLarge!.copyWith(color: c.textPrimary, height: 1.1, letterSpacing: -0.03 * 26),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.4),
                    children: [
                      TextSpan(
                          text: '${l.todayHeaderStats(done, total, maxStreak)} '),
                      TextSpan(
                        text: '🔥',
                        style: context.tt.bodyMedium!.copyWith(color: c.warning),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const _Avatar(initial: 'А'),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.accent, const Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.3),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: context.tt.bodyLarge!.copyWith(color: Colors.white, height: 1, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.tt.headlineSmall!.copyWith(color: color, height: 1.2, letterSpacing: -0.02 * 18),
    );
  }
}

class _TodaySkeletonList extends StatelessWidget {
  const _TodaySkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      children: const [
        _SkeletonHabitCard(),
        SizedBox(height: HFTokens.s12),
        _SkeletonHabitCard(),
        SizedBox(height: HFTokens.s12),
        _SkeletonHabitCard(),
      ],
    );
  }
}

class _SkeletonHabitCard extends StatelessWidget {
  const _SkeletonHabitCard();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(color: c.border, width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      child: Row(
        children: [
          HFSkeleton(width: 44, height: 44, radius: HFTokens.rMd),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HFSkeleton(width: 140, height: 14, radius: HFTokens.rSm),
                const SizedBox(height: 8),
                HFSkeleton(width: 90, height: 11, radius: HFTokens.rSm),
              ],
            ),
          ),
          const SizedBox(width: 12),
          HFSkeleton(width: 44, height: 28, radius: HFTokens.rFull),
        ],
      ),
    );
  }
}

class _GhostAdd extends StatelessWidget {
  const _GhostAdd({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('➕', style: context.tt.bodyLarge!.copyWith(height: 1)),
            const SizedBox(width: 6),
            Text(
              l.todayAddHabit,
              style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
