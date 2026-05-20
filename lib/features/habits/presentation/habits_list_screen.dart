import 'package:habit_flow/core/config/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/config/tokens.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../shared/widgets/hf_chip.dart';
import '../../../shared/widgets/hf_empty_state.dart';
import '../data/habit_model.dart';
import '../data/habits_filter.dart';
import '../data/habits_providers.dart';
import '../domain/habit_log_status.dart';
import '../domain/habit_status.dart';
import '../domain/habit_type.dart';

/// Tab 2: Привычки (см. docs/design/habits-list.html).
/// Header — sticky title row, search, фильтр-чипсы, строка "N привычек / сортировка",
/// карточки с эмодзи, расписанием, type-badge, heatmap (7 дней), стрик и rate.
class HabitsListScreen extends ConsumerStatefulWidget {
  const HabitsListScreen({super.key});

  @override
  ConsumerState<HabitsListScreen> createState() => _HabitsListScreenState();
}

class _HabitsListScreenState extends ConsumerState<HabitsListScreen> {
  final _searchCtrl = TextEditingController();
  HabitsFilter _filter = const HabitsFilter();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showSortSheet(BuildContext context, AppLocalizations l) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final order in HabitsSortOrder.values)
                ListTile(
                  title: Text(_sortLabel(l, order)),
                  selected: _filter.sortOrder == order,
                  selectedColor: HFColors.of(context).accent,
                  onTap: () {
                    setState(() {
                      _filter = _filter.copyWith(sortOrder: order);
                    });
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _sortLabel(AppLocalizations l, HabitsSortOrder order) {
    switch (order) {
      case HabitsSortOrder.byCreated:
        return l.habitsListSortByCreated;
      case HabitsSortOrder.byStreak:
        return l.habitsListSortByStreak;
      case HabitsSortOrder.byRate:
        return l.habitsListSortByProgress;
    }
  }

  String _activeSortLabel(AppLocalizations l) =>
      _sortLabel(l, _filter.sortOrder);

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    final habitsAsync = ref.watch(habitsStreamProvider);

    // Fail-soft: a stream error from `habits` (RLS hiccup, transient
    // disconnect, expired session) used to paint a full-screen red box.
    // Treat it as an empty list so the user still sees the header,
    // search and CTA — they can pull-to-refresh or retry from there.
    return habitsAsync.when(
      loading: () => _buildContent(context, c, l, const []),
      error: (e, st) {
        // Surface the stack to DevTools for diagnosis but never blank the UI.
        debugPrint('habitsStreamProvider error: $e\n$st');
        return _buildContent(context, c, l, const []);
      },
      data: (habits) => _buildContent(context, c, l, habits),
    );
  }

  Widget _buildContent(
    BuildContext context,
    HFColors c,
    AppLocalizations l,
    List<HabitModel> habits,
  ) {
    final categories = HabitsFilter.categoriesFrom(habits);

    final filtered = _filter.apply(
      habits,
      streakFor: (id) => ref.watch(streakProvider(id)),
      // TODO(real-data): replace with actual per-habit completion rate from logs
      rateFor: (_) => 0,
    );

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _StaticHeader(
                sortOrder: _filter.sortOrder,
                onPickSort: (v) => setState(
                  () => _filter = _filter.copyWith(sortOrder: v),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _StaticSearch(
                controller: _searchCtrl,
                query: _filter.query,
                onChanged: (v) => setState(() {
                  _filter = _filter.copyWith(query: v);
                }),
                onClear: () {
                  _searchCtrl.clear();
                  setState(() => _filter = _filter.copyWith(query: ''));
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Status chips: All / Active / Archive
                      _buildStatusChip(
                        l.habitsListFilterAll,
                        HabitsStatusFilter.all,
                        HabitsFilter.countForStatus(habits, HabitsStatusFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        l.habitsListFilterActive,
                        HabitsStatusFilter.active,
                        HabitsFilter.countForStatus(habits, HabitsStatusFilter.active),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        l.habitsListFilterArchive,
                        HabitsStatusFilter.archive,
                        HabitsFilter.countForStatus(habits, HabitsStatusFilter.archive),
                      ),
                      // Category chips
                      for (final cat in categories) ...[
                        const SizedBox(width: 8),
                        _buildCategoryChip(cat, habits),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l.habitsListCount(filtered.length),
                      style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.4, fontSize: 12.0),
                    ),
                    InkWell(
                      onTap: () => _showSortSheet(context, l),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${l.habitsListSortLabel}: ${_activeSortLabel(l)}',
                              style: context.tt.titleSmall!.copyWith(color: c.accent, height: 1.2),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.chevronDown,
                              size: 14,
                              color: c.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: HFEmptyState(
                      emoji: '🔍',
                      title: l.habitsListEmpty,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _HabitsListCard(
                    habit: filtered[i],
                    onTap: () => context.push('/habits/${filtered[i].id}'),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: _Fab(onTap: () => context.push('/habits/new')),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    String label,
    HabitsStatusFilter status,
    int count,
  ) {
    return HFChip(
      label: label,
      count: count,
      selected: _filter.statusFilter == status && _filter.categoryFilter == null,
      onTap: () => setState(() {
        _filter = _filter.copyWith(
          statusFilter: status,
          categoryFilter: null,
        );
      }),
    );
  }

  Widget _buildCategoryChip(String cat, List<HabitModel> allHabits) {
    final count = allHabits.where((h) => h.category == cat).length;
    final isSelected = _filter.categoryFilter == cat;
    return HFChip(
      label: cat,
      count: count,
      selected: isSelected,
      onTap: () => setState(() {
        _filter = _filter.copyWith(
          categoryFilter: isSelected ? null : cat,
          statusFilter: HabitsStatusFilter.all,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StaticHeader extends ConsumerWidget {
  const _StaticHeader({
    required this.sortOrder,
    required this.onPickSort,
  });

  final HabitsSortOrder sortOrder;
  final ValueChanged<HabitsSortOrder> onPickSort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      color: c.bgPrimary,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              l.habitsListTitle,
              style: context.tt.headlineMedium!.copyWith(color: c.textPrimary, height: 1.2, letterSpacing: -0.02 * 22),
            ),
          ),
          _IconBtn(
            icon: LucideIcons.slidersHorizontal,
            onTap: () => _showSortSheet(context, sortOrder, onPickSort),
          ),
        ],
      ),
    );
  }
}

void _showSortSheet(
  BuildContext context,
  HabitsSortOrder current,
  ValueChanged<HabitsSortOrder> onPick,
) {
  final l = AppLocalizations.of(context);
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) {
      final c = HFColors.of(ctx);
      Widget tile(HabitsSortOrder value, String label) {
        final selected = value == current;
        return ListTile(
          onTap: () {
            onPick(value);
            Navigator.pop(ctx);
          },
          title: Text(
            label,
            style: context.tt.bodyMedium!.copyWith(color: selected ? c.accent : c.textPrimary),
          ),
          trailing: selected
              ? Icon(LucideIcons.check, size: 18, color: c.accent)
              : null,
        );
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(
                l.habitsListSortLabel,
                style: context.tt.titleSmall!.copyWith(color: c.textTertiary, letterSpacing: 0.04 * 13),
              ),
            ),
            tile(HabitsSortOrder.byCreated, l.habitsListSortByCreated),
            tile(HabitsSortOrder.byStreak, l.habitsListSortByStreak),
            tile(HabitsSortOrder.byRate, l.habitsListSortByProgress),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _StaticSearch extends StatelessWidget {
  const _StaticSearch({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        border: Border(bottom: BorderSide(color: c.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: c.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Icon(LucideIcons.search, size: 16, color: c.textTertiary),
            const SizedBox(width: 9),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: context.tt.bodyMedium!.copyWith(color: c.textPrimary, height: 1.4),
                cursorColor: c.accent,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: l.habitsListSearchHint,
                  hintStyle: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.4),
                ),
              ),
            ),
            if (query.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Icon(LucideIcons.x, size: 14, color: c.textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: c.bgTertiary,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: c.textSecondary),
        ),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.accent,
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: 0.45),
                offset: const Offset(0, 6),
                blurRadius: 20,
              ),
              BoxShadow(
                color: c.accent.withValues(alpha: 0.3),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            LucideIcons.plus,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HabitsListCard extends ConsumerWidget {
  const _HabitsListCard({required this.habit, required this.onTap});

  final HabitModel habit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = HFColors.of(context);
    final l = AppLocalizations.of(context);

    final streak = ref.watch(streakProvider(habit.id));
    final heatmapAsync =
        ref.watch(habitHeatmapProvider((habitId: habit.id, daysBack: 7)));
    final heatmap = heatmapAsync.value ?? const {};

    final today = ref.watch(todayProvider);
    final cells = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return heatmap[day];
    });

    final isArchived = habit.status == HabitStatus.archived;
    final isPaused = habit.status == HabitStatus.paused;
    final isAnti = habit.type == HabitType.anti;

    final streakColor = isAnti
        ? c.anti
        : isPaused
            ? c.textTertiary
            : c.warning;
    final streakEmoji = isAnti ? '🛡️' : '🔥';

    final iconBg = isPaused
        ? c.bgTertiary
        : isAnti
            ? c.anti.withValues(alpha: 0.12)
            : _accentColor(habit).withValues(alpha: 0.12);

    final borderColor = isAnti ? c.anti.withValues(alpha: 0.2) : c.border;

    final streakBg = isPaused
        ? c.textTertiary.withValues(alpha: 0.1)
        : isAnti
            ? c.anti.withValues(alpha: 0.1)
            : c.warning.withValues(alpha: 0.1);

    final typeBadgeColor = _typeBadgeColor(habit, c, isPaused);

    final card = Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: HFTokens.cardShadow(c.shadow),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg,
                  border: isAnti
                      ? Border.all(
                          color: c.anti.withValues(alpha: 0.25),
                          width: 1.5,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  habit.emoji ?? _fallbackEmoji(habit.type),
                  style: context.tt.headlineMedium!.copyWith(height: 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.tt.titleMedium!.copyWith(color: isPaused ? c.textSecondary : c.textPrimary, height: 1.3),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          _scheduleLabel(habit, l),
                          style: context.tt.bodySmall!.copyWith(color: c.textTertiary, height: 1.4, fontSize: 12.0),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: typeBadgeColor.withValues(alpha: 24 / 255),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _typeBadgeLabel(habit.type, l),
                            style: context.tt.bodyMedium!.copyWith(color: typeBadgeColor, height: 1.4, letterSpacing: 0.03 * 10, fontWeight: FontWeight.w700, fontSize: 10.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _Heatmap(cells: cells),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 52),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: streakBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            streakEmoji,
                            style: context.tt.titleMedium!.copyWith(height: 1),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$streak',
                            style: context.tt.headlineSmall!.copyWith(color: streakColor, height: 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      LucideIcons.moreHorizontal,
                      size: 18,
                      color: c.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isArchived)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF9CA3AF).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l.habitCardArchiveBadge,
                  style: context.tt.bodyMedium!.copyWith(color: c.textTertiary, height: 1.2, letterSpacing: 0.04 * 10, fontWeight: FontWeight.w700, fontSize: 10.0),
                ),
              ),
            ),
        ],
      ),
    );

    final wrapped = isArchived
        ? Opacity(
            opacity: 0.5,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.7945, 0.2415, 0.0640, 0, 0,
                0.2945, 0.7415, 0.0640, 0, 0,
                0.2945, 0.2415, 0.5640, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: card,
            ),
          )
        : card;

    if (isArchived) return wrapped;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: wrapped,
      ),
    );
  }

  Color _accentColor(HabitModel h) {
    if (h.accentColor == null) return const Color(0xFF3B82F6);
    try {
      final hex = h.accentColor!.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF3B82F6);
    }
  }

  Color _typeBadgeColor(HabitModel h, HFColors c, bool isPaused) {
    if (isPaused) return c.textTertiary;
    switch (h.type) {
      case HabitType.binary:
        return const Color(0xFF3B82F6);
      case HabitType.countable:
        return const Color(0xFF06B6D4);
      case HabitType.timed:
        return const Color(0xFF22C55E);
      case HabitType.anti:
        return const Color(0xFF10B981);
    }
  }

  String _typeBadgeLabel(HabitType type, AppLocalizations l) {
    switch (type) {
      case HabitType.binary:
        return l.habitTypeBinary;
      case HabitType.countable:
        return l.habitTypeCountable;
      case HabitType.timed:
        return l.habitTypeTimed;
      case HabitType.anti:
        return l.habitTypeAnti;
    }
  }

  String _fallbackEmoji(HabitType type) {
    switch (type) {
      case HabitType.binary:
        return '✅';
      case HabitType.countable:
        return '🔢';
      case HabitType.timed:
        return '⏱';
      case HabitType.anti:
        return '🛡️';
    }
  }

  String _scheduleLabel(HabitModel h, AppLocalizations l) {
    // TODO(real-data): replace with proper schedule localisation
    final times = h.reminderTimes.isNotEmpty ? ' · ${h.reminderTimes.first}' : '';
    switch (h.scheduleType.wireName) {
      case 'daily':
        return 'Every day$times';
      case 'weekdays':
        final days = (h.schedule['weekdays'] as List? ?? const [])
            .cast<num>()
            .map((n) => _dayAbbr(n.toInt()))
            .join(', ');
        return '$days$times';
      default:
        return h.scheduleType.wireName;
    }
  }

  String _dayAbbr(int iso) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (iso < 1 || iso > 7) return '?';
    return names[iso - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.cells});

  final List<HabitLogStatus?> cells;

  @override
  Widget build(BuildContext context) {
    final c = HFColors.of(context);
    return Row(
      children: [
        for (int i = 0; i < cells.length; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          _heatCell(cells[i], c),
        ],
      ],
    );
  }

  Widget _heatCell(HabitLogStatus? status, HFColors c) {
    final Color color;
    final double opacity;
    switch (status) {
      case HabitLogStatus.done:
      case HabitLogStatus.partial:
        color = c.success;
        opacity = 1;
      case HabitLogStatus.missed:
        color = c.danger;
        opacity = 1;
      case HabitLogStatus.skipped:
        color = c.bgTertiary;
        opacity = 1;
      case null:
        color = c.bgTertiary;
        opacity = 0.5;
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
