import 'dart:math' as math;

import 'package:habit_flow/core/config/text_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/services/telegram_service.dart';
import '../../habits/data/habit_log_model.dart';
import '../../habits/data/habit_model.dart';
import '../../habits/data/habits_providers.dart';
import '../../journal/data/journal_entry_model.dart';
import '../../journal/data/journal_providers.dart';
import '../data/analytics_providers.dart';
import '../data/correlations_provider.dart';
import '../domain/date_range.dart';
import '../domain/day_of_week.dart';
import 'widgets/weekly_review_checklist.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key, this.showWeeklyReview = false});

  /// Принудительно показать чеклист (используется в тестах и при ?review=1).
  final bool showWeeklyReview;

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isWeek = true;
  int? _selectedBar;
  bool _reviewVisible = false;

  // The anchor day whose week/month the user is currently viewing.
  DateTime _periodAnchor = () {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }();

  @override
  void initState() {
    super.initState();
    _reviewVisible = widget.showWeeklyReview;
    if (!_reviewVisible) {
      // Defer go_router lookup until after first frame so context is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkReviewParam());
    }
  }

  void _checkReviewParam() {
    if (!mounted) return;
    try {
      final state = GoRouterState.of(context);
      if (state.uri.queryParameters['review'] == '1') {
        setState(() => _reviewVisible = true);
      }
    } catch (_) {
      // If GoRouter is not available (tests / non-routed contexts) — skip.
    }
  }

  void _dismissReview() => setState(() => _reviewVisible = false);

  void _shareSummary({
    required String periodLabel,
    required int completionPct,
    required int doneCount,
    required int missedCount,
  }) {
    // Aggregate-only by SPEC §15: no entry text, no habit names, no name.
    final text = '📊 HabitFlow · $periodLabel\n'
        '✅ $doneCount выполнено · ❌ $missedCount пропущено\n'
        '🎯 $completionPct% завершено';
    final url = Uri.encodeComponent('https://t.me/habitflow_dev');
    final shareUrl =
        'https://t.me/share/url?url=$url&text=${Uri.encodeComponent(text)}';
    const TelegramService().openLink(shareUrl);
  }

  void _shiftPeriod(int delta) {
    setState(() {
      _selectedBar = null;
      if (_isWeek) {
        _periodAnchor = _periodAnchor.add(Duration(days: 7 * delta));
      } else {
        final m = _periodAnchor.month + delta;
        _periodAnchor = DateTime(_periodAnchor.year + ((m - 1) ~/ 12), ((m - 1) % 12) + 1, 1);
      }
    });
  }

  String _periodLabel(BuildContext context) {
    if (_isWeek) {
      final range = DateRange.weekOf(_periodAnchor);
      final f = range.from;
      final t = range.to;
      final locale = Localizations.localeOf(context).languageCode;
      final monthFmt = DateFormat('MMM', locale);
      if (f.month == t.month) {
        return '${f.day}–${t.day} ${monthFmt.format(f)} ${f.year}';
      }
      return '${f.day} ${monthFmt.format(f)} – ${t.day} ${monthFmt.format(t)} ${t.year}';
    } else {
      final locale = Localizations.localeOf(context).languageCode;
      return DateFormat('MMMM yyyy', locale).format(_periodAnchor);
    }
  }

  // ─── Helpers that derive chart data from providers ───────────────────────

  List<HabitLogModel> _allLogsInRange(
    List<HabitModel> habits,
    DateRange range,
  ) {
    final out = <HabitLogModel>[];
    for (final h in habits) {
      final async = ref.watch(habitLogsForHabitProvider(h.id));
      final list = async.valueOrNull;
      if (list == null) continue;
      for (final l in list) {
        if (range.contains(l.date)) out.add(l);
      }
    }
    return out;
  }

  /// Bar chart data: for weekly view 7 bars (Mon–Sun from byDayOfWeek),
  /// for monthly view one bar per calendar day in the month.
  List<_DayValue> _barData(
    AnalyticsStats stats,
    List<HabitModel> habits,
    DateRange range,
  ) {
    if (_isWeek) {
      const order = DayOfWeek.values; // Mon..Sun
      return [
        for (final dow in order)
          _DayValue(
            _dowLabel(dow),
            (stats.byDayOfWeek[dow]! * 100).round().clamp(0, 100),
          ),
      ];
    } else {
      // Per-calendar-day for the month.
      final logs = _allLogsInRange(habits, range);
      final successDays = <DateTime>{};
      final trackedDays = <DateTime>{};
      for (final l in logs) {
        final d = DateTime(l.date.year, l.date.month, l.date.day);
        trackedDays.add(d);
        if (l.isDone || l.isPartial) successDays.add(d);
      }
      final days = range.days;
      return [
        for (var i = 0; i < days; i++) () {
          final day = DateTime(range.from.year, range.from.month, range.from.day + i);
          if (!trackedDays.contains(day)) {
            return _DayValue('${day.day}', 0);
          }
          // All logs that day divided: success count across all habits that day.
          final dayLogs = logs.where((l) =>
              l.date.year == day.year &&
              l.date.month == day.month &&
              l.date.day == day.day).toList();
          if (dayLogs.isEmpty) return _DayValue('${day.day}', 0);
          final ok = dayLogs.where((l) => l.isDone || l.isPartial).length;
          final pct = (ok / dayLogs.length * 100).round().clamp(0, 100);
          return _DayValue('${day.day}', pct);
        }(),
      ];
    }
  }

  /// Mood/energy line: for weekly view one point per day (Mon..Sun);
  /// for monthly view one point per week (4 points: week 1..4).
  List<_MoodPoint> _moodData(
    List<JournalEntryModel> entries,
    DateRange range,
  ) {
    if (_isWeek) {
      final result = <_MoodPoint>[];
      for (var i = 0; i < 7; i++) {
        final day = DateTime(
          range.from.year,
          range.from.month,
          range.from.day + i,
        );
        JournalEntryModel? entry;
        for (final e in entries) {
          if (e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day) {
            entry = e;
            break;
          }
        }
        result.add(_MoodPoint(
          _dowLabelShort(DayOfWeek.values[i]),
          entry?.mood ?? 0,
          entry?.energy ?? 0,
        ));
      }
      return result;
    } else {
      // Monthly: aggregate by ISO week number within the range (up to 5 weeks).
      // Group days into chunks of 7 starting from range.from.
      final weekCount = ((range.days - 1) ~/ 7) + 1;
      return [
        for (var w = 0; w < weekCount; w++) () {
          final weekStart = DateTime(
            range.from.year,
            range.from.month,
            range.from.day + w * 7,
          );
          final weekEnd = DateTime(
            range.from.year,
            range.from.month,
            range.from.day + (w + 1) * 7 - 1,
          );
          final weekEntries = entries.where((e) =>
              !e.date.isBefore(weekStart) && !e.date.isAfter(weekEnd) &&
              range.contains(e.date)).toList();
          int mood = 0;
          int energy = 0;
          if (weekEntries.isNotEmpty) {
            final moodEntries = weekEntries.where((e) => e.mood != null).toList();
            final energyEntries = weekEntries.where((e) => e.energy != null).toList();
            if (moodEntries.isNotEmpty) {
              mood = (moodEntries.map((e) => e.mood!).reduce((a, b) => a + b) /
                      moodEntries.length)
                  .round();
            }
            if (energyEntries.isNotEmpty) {
              energy = (energyEntries.map((e) => e.energy!).reduce((a, b) => a + b) /
                      energyEntries.length)
                  .round();
            }
          }
          return _MoodPoint('Н${w + 1}', mood, energy);
        }(),
      ];
    }
  }

  /// Top-3 habits by completion rate within the period.
  List<_TopHabit> _topHabits(
    List<HabitModel> habits,
    DateRange range,
  ) {
    final logsByHabit = <String, List<HabitLogModel>>{};
    for (final h in habits) {
      final async = ref.watch(habitLogsForHabitProvider(h.id));
      final list = async.valueOrNull;
      if (list == null) continue;
      logsByHabit[h.id] = list.where((l) => range.contains(l.date)).toList();
    }

    final rated = <(HabitModel, int)>[];
    for (final h in habits) {
      final logs = logsByHabit[h.id];
      if (logs == null || logs.isEmpty) continue;
      final ok = logs.where((l) => l.isDone || l.isPartial).length;
      final pct = (ok / logs.length * 100).round().clamp(0, 100);
      rated.add((h, pct));
    }
    rated.sort((a, b) => b.$2.compareTo(a.$2));

    const colors = [
      Color(0xFF22C55E),
      Color(0xFF3B82F6),
      Color(0xFFA855F7),
    ];

    return [
      for (var i = 0; i < math.min(3, rated.length); i++)
        _TopHabit(
          rated[i].$1.emoji ?? '📋',
          rated[i].$1.name,
          rated[i].$2,
          colors[i % colors.length],
        ),
    ];
  }

  /// Category pie slices from stats.byCategory — top 5 by rate, assign colors.
  List<_CategorySlice> _pieSlices(Map<String, double> byCategory) {
    if (byCategory.isEmpty) return const [];
    const colors = [
      Color(0xFF22C55E),
      Color(0xFF3B82F6),
      Color(0xFFF59E0B),
      Color(0xFFA855F7),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFFEF4444),
    ];
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    // Normalise to percentage points that sum to 100.
    final totalRate = top.fold<double>(0, (s, e) => s + e.value);
    if (totalRate == 0) return const [];

    return [
      for (var i = 0; i < top.length; i++)
        _CategorySlice(
          top[i].key.isEmpty ? '—' : top[i].key,
          (top[i].value / totalRate * 100).round().clamp(0, 100),
          colors[i % colors.length],
        ),
    ];
  }

  static String _dowLabel(DayOfWeek dow) {
    switch (dow) {
      case DayOfWeek.monday:
        return 'Пн';
      case DayOfWeek.tuesday:
        return 'Вт';
      case DayOfWeek.wednesday:
        return 'Ср';
      case DayOfWeek.thursday:
        return 'Чт';
      case DayOfWeek.friday:
        return 'Пт';
      case DayOfWeek.saturday:
        return 'Сб';
      case DayOfWeek.sunday:
        return 'Вс';
    }
  }

  static String _dowLabelShort(DayOfWeek dow) => _dowLabel(dow);

  // ─── Derived best day label ───────────────────────────────────────────────

  String _bestDayLabel(Map<DayOfWeek, double> byDow) {
    if (byDow.isEmpty) return '—';
    final best = byDow.entries.reduce((a, b) => a.value >= b.value ? a : b);
    if (best.value == 0) return '—';
    return _dowLabel(best.key);
  }

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final range = _isWeek
        ? DateRange.weekOf(_periodAnchor)
        : DateRange.monthOf(_periodAnchor);

    final stats = _isWeek
        ? ref.watch(weeklyStatsProvider(_periodAnchor))
        : ref.watch(monthlyStatsProvider(_periodAnchor));

    final habits =
        ref.watch(habitsStreamProvider).valueOrNull ?? const <HabitModel>[];
    final entries =
        ref.watch(journalEntriesProvider).valueOrNull ?? const <JournalEntryModel>[];

    final entriesInRange =
        entries.where((e) => range.contains(e.date)).toList();

    final periodLabel = _periodLabel(context);
    final barData = _barData(stats, habits, range);
    final moodData = _moodData(entriesInRange, range);
    final topHabits = _topHabits(habits, range);
    final pieSlices = _pieSlices(stats.byCategory);

    final completionPct = (stats.completionRate * 100).round().clamp(0, 100);

    // Count successful / missed logs in range.
    final allLogs = _allLogsInRange(habits, range);
    final doneCount = allLogs.where((l) => l.isDone || l.isPartial).length;
    final missedCount = allLogs.where((l) => l.isMissed).length;
    final bestDayLabel = _bestDayLabel(stats.byDayOfWeek);
    final bestDayPct = stats.byDayOfWeek.values.isEmpty
        ? 0
        : (stats.byDayOfWeek.values.reduce(math.max) * 100).round();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _AnalyticsStaticHeader(
            isWeek: _isWeek,
            periodLabel: periodLabel,
            onTab: (week) => setState(() {
              _isWeek = week;
              _selectedBar = null;
            }),
            onPrev: () => _shiftPeriod(-1),
            onNext: () => _shiftPeriod(1),
            onShare: () => _shareSummary(
              periodLabel: periodLabel,
              completionPct: completionPct,
              doneCount: doneCount,
              missedCount: missedCount,
            ),
          ),
        ),
        if (_reviewVisible)
          SliverToBoxAdapter(
            child: WeeklyReviewChecklist(onDismiss: _dismissReview),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          sliver: SliverList.list(
            children: [
              _SummaryCard(
                isWeek: _isWeek,
                periodLabel: periodLabel,
                completionPct: completionPct,
              ),
              const SizedBox(height: 12),
              _MetricsGrid(
                doneCount: doneCount,
                missedCount: missedCount,
                bestDayLabel: bestDayLabel,
                bestDayPct: bestDayPct,
                currentStreak: stats.currentStreak,
                bestStreak: stats.bestStreak,
              ),
              const SizedBox(height: 12),
              _BarChartCard(
                data: barData,
                selectedIdx: _selectedBar,
                onSelect: (i) => setState(() => _selectedBar = i),
              ),
              if (!_isWeek) ...[
                const SizedBox(height: 12),
                _HeatmapCard(data: barData),
              ],
              const SizedBox(height: 12),
              _PieCard(slices: pieSlices, card: c.card),
              const SizedBox(height: 12),
              _MoodLineCard(data: moodData, card: c.card),
              const SizedBox(height: 12),
              _TopHabitsCard(habits: topHabits),
              const SizedBox(height: 12),
              const _AiCorrelationsCard(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────── Helpers

Color _barColor(int v) {
  if (v < 40) return const Color(0xFFEF4444);
  if (v < 70) return const Color(0xFFF59E0B);
  return const Color(0xFF22C55E);
}

Color _heatmapColor(int v) {
  if (v < 30) return const Color(0xFFEF4444).withValues(alpha: 0.2);
  if (v < 50) return const Color(0xFFEF4444).withValues(alpha: 0.5);
  if (v < 70) return const Color(0xFFF59E0B).withValues(alpha: 0.5);
  if (v < 85) return const Color(0xFF22C55E).withValues(alpha: 0.5);
  return const Color(0xFF22C55E).withValues(alpha: 0.9);
}

class _DayValue {
  const _DayValue(this.label, this.value);
  final String label;
  final int value;
}

class _MoodPoint {
  const _MoodPoint(this.label, this.mood, this.energy);
  final String label;
  final int mood;
  final int energy;
}

class _CategorySlice {
  const _CategorySlice(this.label, this.pct, this.color);
  final String label;
  final int pct;
  final Color color;
}

class _TopHabit {
  const _TopHabit(this.emoji, this.name, this.pct, this.color);
  final String emoji;
  final String name;
  final int pct;
  final Color color;
}

// ─────────────────────────────────────── Sticky Header

class _AnalyticsStaticHeader extends StatelessWidget {
  const _AnalyticsStaticHeader({
    required this.isWeek,
    required this.periodLabel,
    required this.onTab,
    required this.onPrev,
    required this.onNext,
    required this.onShare,
  });

  final bool isWeek;
  final String periodLabel;
  final ValueChanged<bool> onTab;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
        boxShadow: [
          BoxShadow(color: c.shadow, offset: const Offset(0, 1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).analyticsTitle,
                    style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 22),
                  ),
                ),
                _IconButton(
                  size: 36,
                  icon: LucideIcons.share2,
                  onTap: onShare,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SegmentedTabs(isWeek: isWeek, onTab: onTab),
          ),
          _PeriodNav(label: periodLabel, onPrev: onPrev, onNext: onNext),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.isWeek, required this.onTab});

  final bool isWeek;
  final ValueChanged<bool> onTab;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.bgTertiary,
        borderRadius: BorderRadius.circular(HFTokens.rMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentedItem(
              label: l.analyticsWeekTab,
              selected: isWeek,
              onTap: () => onTab(true),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: _SegmentedItem(
              label: l.analyticsMonthTab,
              selected: !isWeek,
              onTap: () => onTab(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedItem extends StatelessWidget {
  const _SegmentedItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.bgPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: c.textPrimary.withValues(alpha: 0.1),
                      offset: const Offset(0, 1),
                      blurRadius: 6,
                    ),
                  ]
                : null,
            border: selected
                ? Border.all(
                    color: c.textPrimary.withValues(alpha: 0.04),
                    width: 1,
                  )
                : null,
          ),
          child: Text(
            label,
            style: context.tt.labelLarge!.copyWith(color: selected ? c.textPrimary : c.textTertiary, height: 1.2),
          ),
        ),
      ),
    );
  }
}

class _PeriodNav extends StatelessWidget {
  const _PeriodNav({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      child: Row(
        children: [
          _IconButton(size: 32, icon: LucideIcons.chevronLeft, onTap: onPrev),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.01 * 15),
              ),
            ),
          ),
          _IconButton(size: 32, icon: LucideIcons.chevronRight, onTap: onNext),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.size,
    required this.icon,
    required this.onTap,
  });

  final double size;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.border, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: c.textSecondary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────── Section card shell

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.background,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? c.card,
        borderRadius: BorderRadius.circular(HFTokens.rLg),
        border: Border.all(color: c.border, width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      child: child,
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Text(
      text,
      style: context.tt.titleMedium!.copyWith(color: c.textPrimary, height: 1.2),
    );
  }
}

// ─────────────────────────────────────── Summary

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.isWeek,
    required this.periodLabel,
    required this.completionPct,
  });

  final bool isWeek;
  final String periodLabel;
  final int completionPct;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return _SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.analyticsSummaryLabel,
                  style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.2, letterSpacing: 0.06 * 11),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completionPct%',
                  style: context.tt.displayLarge!.copyWith(color: c.textPrimary, height: 1, letterSpacing: -0.03 * 52, fontSize: 52.0),
                ),
                const SizedBox(height: 6),
                // Trend row: static placeholder — real trend requires prev period data.
                // TODO(real-data): compute delta vs previous week/month.
                const SizedBox.shrink(),
                const SizedBox(height: 3),
                Text(
                  l.analyticsSubtextPeriod(periodLabel),
                  style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.2, fontSize: 12.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _MiniDonut(value: completionPct),
        ],
      ),
    );
  }
}

class _MiniDonut extends StatelessWidget {
  const _MiniDonut({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return SizedBox(
      width: 68,
      height: 68,
      child: CustomPaint(
        painter: _DonutPainter(
          value: value.toDouble(),
          track: c.bgTertiary,
          fill: const Color(0xFF22C55E),
        ),
        child: Center(
          child: Text(
            '$value%',
            style: context.tt.labelMedium!.copyWith(color: c.textPrimary, height: 1),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.value, required this.track, required this.fill});

  final double value;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 7.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);

    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = fill;
    final sweep = (value / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.value != value || old.track != track || old.fill != fill;
}

// ─────────────────────────────────────── Metrics grid

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.doneCount,
    required this.missedCount,
    required this.bestDayLabel,
    required this.bestDayPct,
    required this.currentStreak,
    required this.bestStreak,
  });

  final int doneCount;
  final int missedCount;
  final String bestDayLabel;
  final int bestDayPct;
  final int currentStreak;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final metrics = [
      _MetricData(
        label: l.analyticsMetricCompleted,
        value: '$doneCount',
        icon: LucideIcons.checkCircle2,
        color: const Color(0xFF22C55E),
      ),
      _MetricData(
        label: l.analyticsMetricSkipped,
        value: '$missedCount',
        icon: LucideIcons.xCircle,
        color: const Color(0xFFEF4444),
      ),
      _MetricData(
        label: l.analyticsMetricBestDay,
        value: bestDayLabel,
        sub: bestDayPct > 0 ? '$bestDayPct%' : null,
        icon: LucideIcons.trophy,
        color: const Color(0xFFF59E0B),
      ),
      _MetricData(
        label: l.analyticsMetricStreaks,
        value: '$currentStreak',
        sub: l.analyticsMetricStreaksSubtext,
        icon: LucideIcons.trendingUp,
        color: const Color(0xFF3B82F6),
      ),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricTile(data: metrics[0])),
            const SizedBox(width: 10),
            Expanded(child: _MetricTile(data: metrics[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _MetricTile(data: metrics[2])),
            const SizedBox(width: 10),
            Expanded(child: _MetricTile(data: metrics[3])),
          ],
        ),
      ],
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.sub,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? sub;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data});
  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return _SectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          const SizedBox(height: 10),
          Text(
            data.label.toUpperCase(),
            style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.2, letterSpacing: 0.04 * 11),
          ),
          const SizedBox(height: 3),
          Text(
            data.value,
            style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.1, letterSpacing: -0.02 * 24, fontSize: 24.0),
          ),
          if (data.sub != null) ...[
            const SizedBox(height: 2),
            Text(
              data.sub!,
              style: context.tt.labelSmall!.copyWith(color: data.color, height: 1.2),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────── Bar chart card

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({
    required this.data,
    required this.selectedIdx,
    required this.onSelect,
  });

  final List<_DayValue> data;
  final int? selectedIdx;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CardHeading(AppLocalizations.of(context).analyticsBarChartTitle),
              if (selectedIdx != null)
                RichText(
                  text: TextSpan(
                    style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.2, fontSize: 12.0),
                    children: [
                      TextSpan(text: '${data[selectedIdx!].label}: '),
                      TextSpan(
                        text: '${data[selectedIdx!].value}%',
                        style: context.tt.labelLarge!.copyWith(color: _barColor(data[selectedIdx!].value)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 130,
            child: _BarChart(
              data: data,
              selectedIdx: selectedIdx,
              onSelect: onSelect,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: const Color(0xFFEF4444),
                label: AppLocalizations.of(context).analyticsLegendLow,
              ),
              const SizedBox(width: 12),
              _LegendDot(
                color: const Color(0xFFF59E0B),
                label: AppLocalizations.of(context).analyticsLegendMedium,
              ),
              const SizedBox(width: 12),
              _LegendDot(
                color: const Color(0xFF22C55E),
                label: AppLocalizations.of(context).analyticsLegendHigh,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.2),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.data,
    required this.selectedIdx,
    required this.onSelect,
  });

  final List<_DayValue> data;
  final int? selectedIdx;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final isFew = data.length <= 7;
    final showLabels = isFew;

    final groups = <BarChartGroupData>[];
    for (var i = 0; i < data.length; i++) {
      final v = data[i].value.toDouble();
      final color = _barColor(data[i].value);
      final isSelected = selectedIdx == i;
      final dim = selectedIdx != null && !isSelected;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: v,
              color: color.withValues(alpha: dim ? 0.25 : 1),
              width: isFew ? 28 : 7,
              borderRadius: BorderRadius.circular(isFew ? 5 : 2),
              borderSide: isSelected
                  ? BorderSide(
                      color: color.withValues(alpha: 0.5),
                      width: 2,
                    )
                  : BorderSide.none,
            ),
          ],
        ),
      );
    }

    final chart = BarChart(
      BarChartData(
        maxY: 100,
        minY: 0,
        alignment: isFew
            ? BarChartAlignment.spaceAround
            : BarChartAlignment.spaceBetween,
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions) return;
            final idx = response?.spot?.touchedBarGroupIndex;
            if (idx == null) return;
            onSelect(selectedIdx == idx ? null : idx);
          },
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: c.border,
            strokeWidth: 1,
            dashArray: const [3, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 25,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '${value.toInt()}%',
                    style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1, fontSize: 9.0),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showLabels,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                final isSelected = selectedIdx == i;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[i].label,
                    style: context.tt.labelSmall!.copyWith(color: isSelected ? c.textPrimary : c.textTertiary, height: 1),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: groups,
      ),
    );

    return chart;
  }
}

// ─────────────────────────────────────── Heatmap (month only)

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.data});
  final List<_DayValue> data;

  static const _days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeading(AppLocalizations.of(context).analyticsHeatmapTitle),
            const SizedBox(height: 14),
            _HeatmapGrid(data: data, days: _days),
            const SizedBox(height: 12),
            const _HeatmapLegend(),
          ],
        ),
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.data, required this.days});

  final List<_DayValue> data;
  final List<String> days;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    const cellSize = 30.0;
    const gap = 4.0;
    const startPad = 1;
    final padded = <_DayValue?>[
      ...List.filled(startPad, null),
      ...data,
    ];
    final weeks = <List<_DayValue?>>[];
    for (var i = 0; i < padded.length; i += 7) {
      weeks.add(padded.sublist(i, math.min(i + 7, padded.length)));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: Column(
              children: [
                for (final d in days) ...[
                  if (d != days.first) const SizedBox(height: gap),
                  SizedBox(
                    width: 20,
                    height: cellSize,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Text(
                          d,
                          style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1, fontWeight: FontWeight.w600, fontSize: 9.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: gap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var wi = 0; wi < weeks.length; wi++) ...[
                if (wi > 0) const SizedBox(width: gap),
                _HeatmapColumn(
                  weekIdx: wi,
                  cells: weeks[wi],
                  cellSize: cellSize,
                  gap: gap,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HeatmapColumn extends StatelessWidget {
  const _HeatmapColumn({
    required this.weekIdx,
    required this.cells,
    required this.cellSize,
    required this.gap,
  });

  final int weekIdx;
  final List<_DayValue?> cells;
  final double cellSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Column(
      children: [
        SizedBox(
          height: 18,
          child: Center(
            child: Text(
              '${weekIdx + 1}н',
              style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1, fontWeight: FontWeight.w600, fontSize: 9.0),
            ),
          ),
        ),
        for (var i = 0; i < cells.length; i++) ...[
          SizedBox(height: gap),
          _HeatmapCell(cell: cells[i], size: cellSize),
        ],
      ],
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({required this.cell, required this.size});

  final _DayValue? cell;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    if (cell == null) {
      return SizedBox(width: size, height: size);
    }
    final v = cell!.value;
    final fillColor = _heatmapColor(v);
    final textColor = v >= 70 ? Colors.white : c.textSecondary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        cell!.label,
        style: context.tt.bodyMedium!.copyWith(color: textColor, height: 1, fontWeight: FontWeight.w700, fontSize: 8.0),
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
    final swatches = [
      const Color(0xFFEF4444).withValues(alpha: 0.2),
      const Color(0xFFEF4444).withValues(alpha: 0.5),
      const Color(0xFFF59E0B).withValues(alpha: 0.5),
      const Color(0xFF22C55E).withValues(alpha: 0.5),
      const Color(0xFF22C55E).withValues(alpha: 0.9),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l.analyticsHeatmapLess,
          style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.2, fontSize: 10.0),
        ),
        for (final color in swatches)
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
        Text(
          l.analyticsHeatmapMore,
          style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.2, fontSize: 10.0),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────── Pie

class _PieCard extends StatelessWidget {
  const _PieCard({required this.slices, required this.card});

  final List<_CategorySlice> slices;
  final Color card;

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) {
      return _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeading(AppLocalizations.of(context).analyticsPieTitle),
            const SizedBox(height: 14),
            _EmptyPlaceholder(),
          ],
        ),
      );
    }
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(AppLocalizations.of(context).analyticsPieTitle),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 28,
                    startDegreeOffset: -90,
                    sections: [
                      for (final s in slices)
                        PieChartSectionData(
                          value: s.pct.toDouble(),
                          color: s.color,
                          showTitle: false,
                          radius: 22,
                          borderSide: BorderSide(color: card, width: 2),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < slices.length; i++) ...[
                      if (i > 0) const SizedBox(height: 7),
                      _PieLegendRow(slice: slices[i]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieLegendRow extends StatelessWidget {
  const _PieLegendRow({required this.slice});
  final _CategorySlice slice;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            slice.label,
            style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.2, fontSize: 12.0),
          ),
        ),
        Text(
          '${slice.pct}%',
          style: context.tt.labelMedium!.copyWith(color: c.textPrimary, height: 1.2),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────── Mood line

class _MoodLineCard extends StatelessWidget {
  const _MoodLineCard({required this.data, required this.card});

  final List<_MoodPoint> data;
  final Color card;

  @override
  Widget build(BuildContext context) {
    final hasData = data.any((p) => p.mood > 0 || p.energy > 0);
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(AppLocalizations.of(context).analyticsMoodLineTitle),
          const SizedBox(height: 14),
          if (!hasData)
            _EmptyPlaceholder()
          else ...[
            SizedBox(
              height: 130,
              child: _MoodLineChart(data: data, card: card),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LineLegend(
                  color: const Color(0xFF3B82F6),
                  label: AppLocalizations.of(context).analyticsMoodLine,
                ),
                const SizedBox(width: 16),
                _LineLegend(
                  color: const Color(0xFFF59E0B),
                  label: AppLocalizations.of(context).analyticsEnergyLine,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LineLegend extends StatelessWidget {
  const _LineLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.tt.labelSmall!.copyWith(color: c.textSecondary, height: 1.2),
        ),
      ],
    );
  }
}

class _MoodLineChart extends StatelessWidget {
  const _MoodLineChart({required this.data, required this.card});

  final List<_MoodPoint> data;
  final Color card;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final moodSpots = <FlSpot>[
      for (var i = 0; i < data.length; i++)
        if (data[i].mood > 0) FlSpot(i.toDouble(), data[i].mood.toDouble()),
    ];
    final energySpots = <FlSpot>[
      for (var i = 0; i < data.length; i++)
        if (data[i].energy > 0) FlSpot(i.toDouble(), data[i].energy.toDouble()),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 1,
        maxY: 10,
        lineTouchData: const LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          checkToShowHorizontalLine: (v) => [3, 5, 7, 10].contains(v.toInt()),
          getDrawingHorizontalLine: (_) => FlLine(
            color: c.border,
            strokeWidth: 1,
            dashArray: const [3, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, _) {
                if (![3, 5, 7, 10].contains(value.toInt())) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '${value.toInt()}',
                    style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1, fontSize: 9.0),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[i].label,
                    style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1, fontSize: 10.0),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          if (moodSpots.isNotEmpty)
            _lineBar(moodSpots, const Color(0xFF3B82F6), card),
          if (energySpots.isNotEmpty)
            _lineBar(energySpots, const Color(0xFFF59E0B), card),
        ],
      ),
    );
  }

  LineChartBarData _lineBar(List<FlSpot> spots, Color color, Color card) {
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      isStrokeJoinRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
          radius: 3.5,
          color: color,
          strokeWidth: 2,
          strokeColor: card,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────── Top habits

class _TopHabitsCard extends StatelessWidget {
  const _TopHabitsCard({required this.habits});
  final List<_TopHabit> habits;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CardHeading(AppLocalizations.of(context).analyticsTopHabitsTitle),
              Text(
                AppLocalizations.of(context).analyticsTopHabitsSubtitle,
                style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1.2, letterSpacing: 0.05 * 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (habits.isEmpty)
            _EmptyPlaceholder()
          else
            for (var i = 0; i < habits.length; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              _TopHabitRow(rank: i + 1, habit: habits[i]),
            ],
        ],
      ),
    );
  }
}

class _TopHabitRow extends StatelessWidget {
  const _TopHabitRow({required this.rank, required this.habit});

  final int rank;
  final _TopHabit habit;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: c.bgTertiary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: context.tt.labelSmall!.copyWith(color: c.textTertiary, height: 1),
          ),
        ),
        const SizedBox(width: 12),
        Text(habit.emoji, style: context.tt.headlineSmall!.copyWith(height: 1)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      habit.name,
                      overflow: TextOverflow.ellipsis,
                      style: context.tt.labelLarge!.copyWith(color: c.textPrimary, height: 1.2),
                    ),
                  ),
                  Text(
                    '${habit.pct}%',
                    style: context.tt.titleSmall!.copyWith(color: habit.color, height: 1.2),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              _ProgressBar(value: habit.pct, color: habit.color),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(HFTokens.rFull),
      child: Container(
        height: 6,
        color: c.bgTertiary,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (value / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(HFTokens.rFull),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────── AI correlations

/// Lazy until the user taps "Get correlations". Stays at idle on first
/// mount so we don't spend the user's API quota without consent.
final _correlationsRequestedProvider = StateProvider.autoDispose<bool>(
  (_) => false,
);

class _AiCorrelationsCard extends ConsumerWidget {
  const _AiCorrelationsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final requested = ref.watch(_correlationsRequestedProvider);
    final result = requested ? ref.watch(correlationsProvider) : null;

    return _SectionCard(
      background: c.bgSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.bgTertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.sparkles,
                  size: 18,
                  color: c.textTertiary,
                ),
              ),
              const SizedBox(width: 10),
              _CardHeading(l.analyticsAiCorrelationsTitle),
            ],
          ),
          const SizedBox(height: 12),
          if (result == null)
            _IdleBody(
              text: l.analyticsAiCorrelationsMessage,
              cta: l.correlationsRefresh,
              onTap: () =>
                  ref.read(_correlationsRequestedProvider.notifier).state =
                      true,
            )
          else
            result.when(
              loading: () => _LoadingBody(text: l.correlationsLoading),
              error: (e, _) => _ErrorBody(
                error: e,
                onRetry: () => ref.invalidate(correlationsProvider),
              ),
              data: (insights) => _DataBody(
                insights: insights,
                onRefresh: () => ref.invalidate(correlationsProvider),
              ),
            ),
        ],
      ),
    );
  }
}

class _IdleBody extends StatelessWidget {
  const _IdleBody({
    required this.text,
    required this.cta,
    required this.onTap,
  });

  final String text;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          text,
          style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.55),
        ),
        const SizedBox(height: 14),
        _PrimaryRefreshButton(label: cta, onTap: onTap),
      ],
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    final (text, primaryLabel, VoidCallback primaryAction) = switch (error) {
      CorrelationsNoKeyError() => (
          l.correlationsNoKey,
          l.aiSettingsApiKeySection,
          () => context.push('/profile/ai-settings'),
        ),
      CorrelationsNotEnoughDataError(:final logsCount) => (
          l.correlationsNotEnoughData(logsCount),
          l.correlationsRefreshAgain,
          onRetry,
        ),
      CorrelationsRateLimitedError() => (
          l.correlationsRateLimited,
          l.correlationsRefreshAgain,
          onRetry,
        ),
      _ => (
          l.correlationsGeneric,
          l.correlationsRefreshAgain,
          onRetry,
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          text,
          style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.55),
        ),
        const SizedBox(height: 14),
        _PrimaryRefreshButton(label: primaryLabel, onTap: primaryAction),
      ],
    );
  }
}

class _DataBody extends StatelessWidget {
  const _DataBody({required this.insights, required this.onRefresh});

  final List<CorrelationInsight> insights;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    if (insights.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.correlationsEmpty,
            style: context.tt.bodySmall!.copyWith(color: c.textSecondary, height: 1.55),
          ),
          const SizedBox(height: 14),
          _PrimaryRefreshButton(
            label: l.correlationsRefreshAgain,
            onTap: onRefresh,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < insights.length; i++) ...[
          _InsightTile(insight: insights[i]),
          if (i != insights.length - 1) const SizedBox(height: 8),
        ],
        const SizedBox(height: 14),
        _PrimaryRefreshButton(
          label: l.correlationsRefreshAgain,
          onTap: onRefresh,
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});

  final CorrelationInsight insight;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final dirLabel = switch (insight.direction) {
      'up' => l.correlationsDirectionUp,
      'down' => l.correlationsDirectionDown,
      _ => l.correlationsDirectionMixed,
    };
    final dirColor = switch (insight.direction) {
      'up' => c.success,
      'down' => c.danger,
      _ => c.textTertiary,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(HFTokens.rMd),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${insight.habit} · ${insight.factor}',
                  style: context.tt.titleSmall!.copyWith(color: c.textPrimary, height: 1.3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(insight.strength * 100).round()}%',
                style: context.tt.labelMedium!.copyWith(color: c.textTertiary, height: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dirLabel,
            style: context.tt.labelMedium!.copyWith(color: dirColor, height: 1.2),
          ),
          if (insight.note != null && insight.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              insight.note!,
              style: context.tt.bodyMedium!.copyWith(color: c.textSecondary, height: 1.45, fontSize: 12.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrimaryRefreshButton extends StatelessWidget {
  const _PrimaryRefreshButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HFTokens.rMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(HFTokens.rMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.sparkles,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.tt.labelLarge!.copyWith(color: Colors.white, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────── Empty state placeholder

class _EmptyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          '—',
          style: context.tt.headlineSmall!.copyWith(color: c.textTertiary, height: 1, fontSize: 20.0),
        ),
      ),
    );
  }
}
