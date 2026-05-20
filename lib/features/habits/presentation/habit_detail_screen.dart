import 'package:habit_flow/core/config/text_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/config/env.dart';
import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../data/habit_log_model.dart';
import '../data/habit_model.dart';
import '../data/habits_providers.dart';
import 'widgets/habit_more_sheet.dart';
import '../domain/habit_calculations.dart';
import '../domain/habit_log_status.dart';
import '../../analytics/domain/aggregations.dart' as agg;

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitDetailProvider(habitId));
    final c = HFColors.of(context);

    return Scaffold(
      backgroundColor: c.bgSecondary,
      body: SafeArea(
        child: Container(
          color: c.bgPrimary,
          child: habitAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                e.toString(),
                style: context.tt.bodyMedium!.copyWith(color: c.danger),
              ),
            ),
            data: (habit) {
              if (habit == null) {
                return Center(
                  child: Text(
                    '404',
                    style: context.tt.bodyMedium!.copyWith(color: c.textTertiary),
                  ),
                );
              }
              return _DetailBody(habitId: habitId, habit: habit);
            },
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.habitId, required this.habit});

  final String habitId;
  final HabitModel habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(habitLogsForHabitProvider(habitId));
    final streak = ref.watch(streakProvider(habitId));
    final heatmapAsync = ref.watch(
      habitHeatmapProvider((habitId: habitId, daysBack: 90)),
    );

    final logs = logsAsync.value ?? const [];
    final heatmap = heatmapAsync.value ?? {};
    final today = ref.watch(todayProvider);

    final best = agg.bestStreak(logs);
    final last30Start = today.subtract(const Duration(days: 29));
    final last30Logs = logs.where((l) {
      final d = dateOnly(l.date);
      return !d.isBefore(last30Start) && !d.isAfter(today);
    }).toList();

    int scheduled30Count = 0;
    int done30Count = 0;
    final logsMap = {for (final l in last30Logs) dateOnly(l.date): l};
    for (int i = 0; i < 30; i++) {
      final day = last30Start.add(Duration(days: i));
      if (!day.isBefore(dateOnly(habit.startedAt)) && habit.isToday(day)) {
        scheduled30Count++;
        final log = logsMap[day];
        if (log != null &&
            (log.status == HabitLogStatus.done ||
                log.status == HabitLogStatus.partial)) {
          done30Count++;
        }
      }
    }
    final ratePercent = scheduled30Count > 0 ? (done30Count / scheduled30Count * 100).round() : 0;

    final locale = Localizations.localeOf(context).languageCode;
    final heatmapGrid = _buildGrid(heatmap, today);
    final chartData = _buildChartData(habit, logs, today);
    final historyEntries = _buildHistory(logs, today, locale);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            onBack: () => context.pop(),
            onMore: () => _showMenu(context, ref),
          ),
          _Hero(
            name: habit.name,
            emoji: habit.emoji ?? '⭐',
            iconTelegramFileId: habit.iconTelegramFileId,
            category: habit.category ?? '',
            streak: streak,
          ),
          _SectionHeader(label: AppLocalizations.of(context).habitDetailStatistics),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '$streak',
                    label: AppLocalizations.of(context).habitDetailCurrentStreak,
                    color: HFTokens.warning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    value: '$best',
                    label: AppLocalizations.of(context).habitDetailBestStreak,
                    color: HFTokens.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    value: '$ratePercent%',
                    label: AppLocalizations.of(context).habitDetailLast30Days,
                    isAccent: true,
                  ),
                ),
              ],
            ),
          ),
          _SectionHeader(label: AppLocalizations.of(context).habitDetailLast90Days),
          const _HeatmapLegend(),
          _Heatmap(data: heatmapGrid),
          _SectionHeader(label: AppLocalizations.of(context).habitDetailDynamics),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: _ChartCard(data: chartData),
          ),
          _SectionHeader(label: AppLocalizations.of(context).habitDetailBehavior),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onLongPress: () => _showMoreSheet(context, habit),
              child: _BehaviorGrid(habit: habit),
            ),
          ),
          _SectionHeader(label: AppLocalizations.of(context).habitDetailHistory),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _HistoryList(items: historyEntries),
          ),
        ],
      ),
    );
  }

  void _showMoreSheet(BuildContext context, HabitModel habit) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => HabitMoreSheet(
        identity: habit.identityStatement,
        reward: habit.reward,
        implementationWhen: habit.implementationWhen,
        implementationWhere: habit.implementationWhere,
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuItem(
                icon: LucideIcons.edit,
                label: l.commonEdit,
                color: c.textPrimary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/habits/$habitId/edit');
                },
                divider: true,
              ),
              _MenuItem(
                icon: LucideIcons.archive,
                label: l.habitDetailArchive,
                color: c.warning,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _archive(context, ref);
                },
                divider: true,
              ),
              _MenuItem(
                icon: LucideIcons.trash2,
                label: l.commonDelete,
                color: c.danger,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDelete(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    try {
      await ref.read(habitsRepositoryProvider).archive(habitId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.habitDetailArchivedToast)),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.habitDetailDeleteConfirmTitle),
        content: Text(l.habitDetailDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l.commonDelete,
              style: context.tt.labelLarge!.copyWith(color: HFColors.of(context).danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(habitsRepositoryProvider).delete(habitId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.habitDetailDeletedToast)),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data builders
// ─────────────────────────────────────────────────────────────────────────────

List<List<_HeatCell>> _buildGrid(
  Map<DateTime, HabitLogStatus> heatmap,
  DateTime today,
) {
  final todayDate = dateOnly(today);
  var start = todayDate.subtract(const Duration(days: 89));
  // Align to Monday of that week.
  final dow = (start.weekday - 1) % 7; // Mon=0..Sun=6
  start = start.subtract(Duration(days: dow));
  final rangeStart = todayDate.subtract(const Duration(days: 89));

  final grid = <List<_HeatCell>>[];
  // 13 weeks covers 91 days which is enough for 90-day window.
  for (int w = 0; w < 13; w++) {
    final col = <_HeatCell>[];
    for (int d = 0; d < 7; d++) {
      final date = start.add(Duration(days: w * 7 + d));
      final isFuture = date.isAfter(todayDate);
      final inRange = !date.isBefore(rangeStart) && !isFuture;
      _HeatStatus status;
      if (!inRange) {
        status = _HeatStatus.inactive;
      } else {
        final logStatus = heatmap[date];
        status = switch (logStatus) {
          HabitLogStatus.done => _HeatStatus.done,
          HabitLogStatus.partial => _HeatStatus.partial,
          HabitLogStatus.missed => _HeatStatus.missed,
          HabitLogStatus.skipped => _HeatStatus.skip,
          null => _HeatStatus.inactive,
        };
      }
      col.add(_HeatCell(status: status, isFuture: isFuture));
    }
    grid.add(col);
  }
  return grid;
}

List<double> _buildChartData(
  HabitModel habit,
  List<HabitLogModel> logs,
  DateTime today,
) {
  // 26 weekly buckets (most recent = last element).
  const weeks = 26;
  final todayDate = dateOnly(today);
  final result = List<double>.filled(weeks, 0.0);
  final startLimit = dateOnly(habit.startedAt);

  // Group logs by date for O(1) lookup
  final logsMap = {for (final l in logs) dateOnly(l.date): l};

  for (int w = 0; w < weeks; w++) {
    final weekEnd = todayDate.subtract(Duration(days: (weeks - 1 - w) * 7));
    final weekStart = weekEnd.subtract(const Duration(days: 6));
    int done = 0;
    int total = 0;
    for (int d = 0; d < 7; d++) {
      final day = weekStart.add(Duration(days: d));
      if (day.isAfter(todayDate) || day.isBefore(startLimit)) continue;
      if (habit.isToday(day)) {
        total++;
        final log = logsMap[day];
        if (log != null &&
            (log.status == HabitLogStatus.done ||
                log.status == HabitLogStatus.partial)) {
          done++;
        }
      }
    }
    result[w] = total > 0 ? (done / total * 100).roundToDouble() : 0.0;
  }
  return result;
}

List<_HistoryEntry> _buildHistory(
  List<HabitLogModel> logs,
  DateTime today,
  String locale,
) {
  // Take up to 10 most recent logs, sorted newest first.
  final sorted = [...logs]
    ..sort((a, b) => b.date.compareTo(a.date));
  final recent = sorted.take(10).toList();

  final dateFormatter = DateFormat('d MMM, E', locale);

  return recent.map((log) {
    final d = log.date;
    final dateStr = dateFormatter.format(d);
    final status = switch (log.status) {
      HabitLogStatus.done => _HistoryStatus.done,
      HabitLogStatus.partial => _HistoryStatus.done,
      HabitLogStatus.missed => _HistoryStatus.missed,
      HabitLogStatus.skipped => _HistoryStatus.skip,
    };
    return _HistoryEntry(
      date: dateStr,
      status: status,
      comment: log.comment,
    );
  }).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets (UI unchanged from design)
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onMore});

  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundIconButton(
            onTap: onBack,
            background: c.bgTertiary,
            child: Icon(
              LucideIcons.chevronLeft,
              size: 18,
              color: c.textPrimary,
            ),
          ),
          _RoundIconButton(
            onTap: onMore,
            background: c.bgTertiary,
            child: Text(
              '···',
              style: context.tt.headlineSmall!.copyWith(color: c.textPrimary, height: 1, letterSpacing: 2, fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.onTap,
    required this.background,
    required this.child,
  });

  final VoidCallback onTap;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.name,
    required this.emoji,
    this.iconTelegramFileId,
    required this.category,
    required this.streak,
  });

  final String name;
  final String emoji;
  final String? iconTelegramFileId;
  final String category;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    Widget imageContent;
    if (iconTelegramFileId != null && iconTelegramFileId!.isNotEmpty) {
      final imageUrl = '${Env.supabaseUrl}/functions/v1/get_telegram_photo?file_id=$iconTelegramFileId';
      imageContent = ClipOval(
        child: Image.network(
          imageUrl,
          headers: {
            'Authorization': 'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
          },
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(emoji, style: context.tt.displayLarge!.copyWith(height: 1, fontSize: 38.0)),
            );
          },
        ),
      );
    } else {
      imageContent = Text(emoji, style: context.tt.displayLarge!.copyWith(height: 1, fontSize: 38.0));
    }

    return Container(
      color: c.bgPrimary,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HFTokens.success.withValues(alpha: 0.15),
                  c.accent.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(
                color: HFTokens.success.withValues(alpha: 0.20),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: HFTokens.success.withValues(alpha: 0.15),
                  offset: const Offset(0, 4),
                  blurRadius: 20,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: imageContent,
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 22),
          ),
          if (category.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              category,
              style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.2, fontSize: 12.0),
            ),
          ],
          if (streak > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: HFTokens.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: HFTokens.warning.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Text(
                '🔥 ${l.habitDetailCurrentStreak.replaceAll('\n', ' ')}: $streak',
                style: context.tt.titleSmall!.copyWith(color: HFTokens.warning, height: 1.2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        label.toUpperCase(),
        style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.2, letterSpacing: 0.08 * 11),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    this.color,
    this.isAccent = false,
  });

  final String value;
  final String label;
  final Color? color;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final valueColor = isAccent ? c.accent : (color ?? c.textPrimary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: context.tt.displayMedium!.copyWith(color: valueColor, height: 1.1, letterSpacing: -0.03 * 28),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.4, fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final entries = <(Color, String)>[
      (HFTokens.success, l.habitDetailHeatmapDone),
      (const Color(0xFF86EFAC), l.habitDetailHeatmapPartial),
      (HFTokens.danger, l.habitDetailHeatmapMissed),
      (c.bgTertiary, l.habitDetailHeatmapSkip),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (final entry in entries)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: entry.$1,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: const Color(0x0F000000),
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  entry.$2,
                  style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.2, fontSize: 10.0),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.data});

  final List<List<_HeatCell>> data;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final weekdayFormatter = DateFormat('E', locale);
    final days = [
      weekdayFormatter.format(DateTime(2024, 1, 1)), // Monday
      weekdayFormatter.format(DateTime(2024, 1, 2)), // Tuesday
      weekdayFormatter.format(DateTime(2024, 1, 3)), // Wednesday
      weekdayFormatter.format(DateTime(2024, 1, 4)), // Thursday
      weekdayFormatter.format(DateTime(2024, 1, 5)), // Friday
      weekdayFormatter.format(DateTime(2024, 1, 6)), // Saturday
      weekdayFormatter.format(DateTime(2024, 1, 7)), // Sunday
    ];

    Color cellColor(_HeatStatus s) {
      switch (s) {
        case _HeatStatus.done:
          return HFTokens.success;
        case _HeatStatus.partial:
          return const Color(0xFF86EFAC);
        case _HeatStatus.missed:
          return HFTokens.danger;
        case _HeatStatus.skip:
          return c.bgTertiary;
        case _HeatStatus.inactive:
          return Colors.transparent;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < days.length; i++) ...[
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: Center(
                        child: Text(
                          days[i],
                          style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1, fontWeight: FontWeight.w600, fontSize: 8.5),
                        ),
                      ),
                    ),
                    if (i < days.length - 1) const SizedBox(height: 3),
                  ],
                ],
              ),
            ),
            for (int wi = 0; wi < data.length; wi++) ...[
              Column(
                children: [
                  for (int di = 0; di < data[wi].length; di++) ...[
                    Opacity(
                      opacity: data[wi][di].isFuture ? 0.2 : 1,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: cellColor(data[wi][di].status),
                          borderRadius: BorderRadius.circular(3),
                          border: data[wi][di].status == _HeatStatus.inactive
                              ? Border.all(
                                  color: c.border,
                                  width: 1,
                                  style: BorderStyle.solid,
                                )
                              : null,
                        ),
                      ),
                    ),
                    if (di < data[wi].length - 1) const SizedBox(height: 3),
                  ],
                ],
              ),
              if (wi < data.length - 1) const SizedBox(width: 3),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.data});

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final spots = <FlSpot>[
      for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i]),
    ];
    final avg = data.isEmpty
        ? 0
        : (data.reduce((a, b) => a + b) / data.length).round();

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: c.border,
                    strokeWidth: 1,
                    dashArray: const [3, 3],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (value, _) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '${value.toInt()}%',
                          style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1, fontSize: 8.0),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 4,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i % 4 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            l.habitDetailChartWeekShort(i + 1),
                            style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1, fontSize: 8.0),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: HFTokens.success,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    isStrokeJoinRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          HFTokens.success.withValues(alpha: 0.25),
                          HFTokens.success.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => c.card,
                    tooltipBorder: BorderSide(color: c.border),
                    getTooltipItems: (spots) => [
                      for (final s in spots)
                        LineTooltipItem(
                          '${s.y.toInt()}%',
                          context.tt.labelSmall!.copyWith(color: HFTokens.success),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.border, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.habitDetailChartWeeks(data.length),
                  style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.2, fontSize: 10.0),
                ),
                Text(
                  l.habitDetailChartAverage(avg),
                  style: context.tt.bodyMedium!.copyWith(color: HFTokens.success, height: 1.2, fontWeight: FontWeight.w700, fontSize: 10.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BehaviorGrid extends StatelessWidget {
  const _BehaviorGrid({required this.habit});

  // ignore: avoid_dynamic_calls
  final dynamic habit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // ignore: avoid_dynamic_calls
    final stackWhen = habit.implementationWhen as String?;
    // ignore: avoid_dynamic_calls
    final stackWhere = habit.implementationWhere as String?;
    // ignore: avoid_dynamic_calls
    final identity = habit.identityStatement as String?;
    // ignore: avoid_dynamic_calls
    final twoMin = habit.twoMinuteVersion as String?;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _BehaviorCard(
                emoji: '🧱',
                label: l.habitDetailBehaviorAfter,
                value: stackWhen ?? '—',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _BehaviorCard(
                emoji: '📍',
                label: l.habitDetailBehaviorWhere,
                value: stackWhere ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _BehaviorCard(
                emoji: '🎭',
                label: l.habitDetailBehaviorIdentity,
                value: identity ?? '—',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _BehaviorCard(
                emoji: '⚡',
                label: l.habitDetailBehaviorMin,
                value: twoMin ?? '—',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BehaviorCard extends StatelessWidget {
  const _BehaviorCard({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: context.tt.headlineSmall!.copyWith(height: 1, fontSize: 20.0)),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.2, letterSpacing: 0.06 * 10, fontWeight: FontWeight.w700, fontSize: 10.0),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: context.tt.labelMedium!.copyWith(color: c.textPrimary, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items});

  final List<_HistoryEntry> items;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    if (items.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
          boxShadow: HFTokens.cardShadow(c.shadow),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: Text(
            '—',
            style: context.tt.bodySmall!.copyWith(color: c.textTertiary),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++)
            _HistoryItem(
              item: items[i],
              hasDivider: i < items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatefulWidget {
  const _HistoryItem({required this.item, required this.hasDivider});

  final _HistoryEntry item;
  final bool hasDivider;

  @override
  State<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final hasComment = widget.item.comment != null;
    final dot = switch (widget.item.status) {
      _HistoryStatus.done => HFTokens.success,
      _HistoryStatus.missed => HFTokens.danger,
      _HistoryStatus.skip => c.textTertiary,
    };
    final statusEmoji = switch (widget.item.status) {
      _HistoryStatus.done => '✅',
      _HistoryStatus.missed => '❌',
      _HistoryStatus.skip => '⏭',
    };
    final statusLabel = switch (widget.item.status) {
      _HistoryStatus.done => l.habitHistoryStatusDone,
      _HistoryStatus.missed => l.habitHistoryStatusMissed,
      _HistoryStatus.skip => l.habitDetailHeatmapSkip,
    };

    return Material(
      color: _expanded ? c.bgSecondary : Colors.transparent,
      child: InkWell(
        onTap: hasComment ? () => setState(() => _expanded = !_expanded) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: widget.hasDivider
                ? Border(bottom: BorderSide(color: c.border, width: 1))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dot,
                      boxShadow: [
                        BoxShadow(
                          color: dot.withValues(alpha: 0.2),
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              widget.item.date,
                              style: context.tt.titleSmall!.copyWith(color: c.textPrimary, height: 1.2),
                            ),
                            Text(
                              statusEmoji,
                              style: context.tt.bodySmall!.copyWith(height: 1.2, fontSize: 12.0),
                            ),
                            Text(
                              statusLabel,
                              style: context.tt.labelSmall!.copyWith(color: dot, height: 1.2),
                            ),
                          ],
                        ),
                        if (hasComment && !_expanded) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.item.comment!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.tt.labelSmall!.copyWith(color: c.textSecondary, height: 1.4, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasComment) ...[
                    const SizedBox(width: 8),
                    Icon(
                      _expanded
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown,
                      size: 13,
                      color: c.textTertiary,
                    ),
                  ],
                ],
              ),
              if (_expanded && hasComment) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.comment!,
                        style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.6, fontStyle: FontStyle.italic, fontSize: 12.0),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: c.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: c.accent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          l.habitDetailHistoryEdit,
                          style: context.tt.labelSmall!.copyWith(color: c.accent, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.divider = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: divider
              ? Border(bottom: BorderSide(color: c.border, width: 1))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: context.tt.bodyMedium!.copyWith(color: color, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Local value types
// ─────────────────────────────────────────────────────────────────────────────

enum _HeatStatus { done, partial, missed, skip, inactive }

class _HeatCell {
  const _HeatCell({required this.status, required this.isFuture});
  final _HeatStatus status;
  final bool isFuture;
}

enum _HistoryStatus { done, missed, skip }

class _HistoryEntry {
  const _HistoryEntry({
    required this.date,
    required this.status,
    this.comment,
  });
  final String date;
  final _HistoryStatus status;
  final String? comment;
}
